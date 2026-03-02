const { onCall } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const crypto = require("crypto");

admin.initializeApp();
const db = admin.firestore();

const PAYU_KEY = process.env.PAYU_KEY;
const PAYU_SALT = process.env.PAYU_SALT;

exports.createPayuPayment = onCall(async (request) => {

  // 🔐 Ensure user is authenticated
  if (!request.auth) {
    throw new Error("User must be authenticated");
  }

  const uid = request.auth.uid;

  const amount = "379";
  const productinfo = "Recharge Subscription";
  const firstname = request.data.firstname || "User";
  const email = request.data.email || "test@email.com";

  const txnid = crypto.randomUUID();

  const hashString =
    PAYU_KEY + "|" +
    txnid + "|" +
    amount + "|" +
    productinfo + "|" +
    firstname + "|" +
    email +
    "|||||||||||" +
    PAYU_SALT;

  const hash = crypto
    .createHash("sha512")
    .update(hashString)
    .digest("hex");

  await db.collection("transactions").doc(txnid).set({
    uid,
    txnid,
    amount,
    status: "INITIATED",
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  });

  return {
    key: PAYU_KEY,
    txnid,
    amount,
    productinfo,
    firstname,
    email,
    hash,
    surl: "https://us-central1-rechargepro-app.cloudfunctions.net/payuCallback",
    furl: "https://us-central1-rechargepro-app.cloudfunctions.net/payuCallback"
  };
});

const { onRequest } = require("firebase-functions/v2/https");

exports.payuCallback = onRequest(async (req, res) => {
  try {
    const {
      txnid,
      status,
      amount,
      firstname,
      email,
      hash,
    } = req.body;

    if (!txnid) {
      return res.status(400).send("Invalid request");
    }

    const transactionRef = db.collection("transactions").doc(txnid);
    const transactionSnap = await transactionRef.get();

    if (!transactionSnap.exists) {
      return res.status(404).send("Transaction not found");
    }

    const transactionData = transactionSnap.data();
    const uid = transactionData.uid;

    // 🔐 Recompute hash (reverse format for response verification)
    const hashString =
      PAYU_SALT + "|" +
      status + "|||||||||||" +
      email + "|" +
      firstname + "|" +
      "Recharge Subscription" + "|" +
      amount + "|" +
      txnid + "|" +
      PAYU_KEY;

    const generatedHash = crypto
      .createHash("sha512")
      .update(hashString)
      .digest("hex");

    if (generatedHash !== hash) {
      await transactionRef.update({ status: "HASH_MISMATCH" });
      return res.status(400).send("Hash mismatch");
    }

    if (status === "success") {
      const now = new Date();
      const subscriptionEnd = new Date(
        now.getFullYear() + 1,
        now.getMonth(),
        now.getDate()
      );

      // 🔥 Update transaction
      await transactionRef.update({
        status: "SUCCESS",
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      // 🔥 Activate subscription
      await db.collection("users").doc(uid).update({
        subscriptionState: "ACTIVE",
        subscriptionEnd: subscriptionEnd
      });

      return res.status(200).send("Payment verified");
    } else {
      await transactionRef.update({ status: "FAILED" });
      return res.status(200).send("Payment failed");
    }

  } catch (error) {
    console.error(error);
    return res.status(500).send("Server error");
  }
});

