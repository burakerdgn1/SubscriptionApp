const functions = require('firebase-functions')
const admin = require('firebase-admin')
const cors = require('cors')({ origin: true })

admin.initializeApp(functions.config().firebase)

const updateClaims = (uid) => admin.auth().setCustomUserClaims(uid, {
  'https://hasura.io/jwt/claims': {
    'x-hasura-default-role': 'user',
    'x-hasura-allowed-roles': ['user'],
    'x-hasura-user-id': uid,
  },
})

exports.processSignUp = functions.auth.user().onCreate((user) => updateClaims(user.uid))

exports.refreshToken = functions.https.onRequest((req, res) => {
  console.log('TOKEN REFRESH', req.query.uid)
  cors(req, res, () => {
    updateClaims(req.query.uid).then(() => {
      res.status(200).send('success')
    }).catch((error) => {
      console.error('REFRESH ERROR', error)
      res.status(400).send(error)
    })
  })
})