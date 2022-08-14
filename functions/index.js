//after making changes in index pass firebase deploy in terminal

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
var fireDb = admin.firestore();
var fcm = admin.messaging();

exports.notifyPlanRequest = functions.firestore
    .document('Notifications/{uid}/planRequest/{planRequestId}')
    .onCreate(async (snapshot,context) => {
        const data = snapshot.data();
        var userId = context.params.uid;
        var docId = context.params.planRequestId;
        if(docId != "count"){
            if(data.request == "received"){
                const querySnapshot = fireDb.collection("users")
                .doc(userId).collection('devices')
                .get();

                var tokens = [];
                var platforms = [];

                (await querySnapshot).docs.map((snap) => {
                    tokens.push(snap.data().token);
                    platforms.push(snap.data().platform);
                });

                functions.logger.log("Tokens: ", tokens);
                functions.logger.log("Platforms: ", platforms);

                payload = "";

                for(const index in platforms) {
                    fcm.send({
                      token: tokens[index],
                      data:{
                          title:'LitPie | Plan Request',
                          body: data.userName + ' sent you a plan request.',
                          click_action:'FLUTTER_NOTIFICATION_CLICK',
                          screen:"plan_notification",
                          sound:"false",
                          vibrate:"true",
                      },
                      // Add APNS (Apple) config
                      apns: {
                        payload: {
                          aps: {
                            contentAvailable: true,
                           },
                        },
                        headers: {
                          "apns-push-type": "background",
                          "apns-priority": "5", // Must be `5` when `contentAvailable` is set to true.
                          "apns-topic": "io.flutter.plugins.firebase.messaging", // bundle identifier
                        },
                      },
                    });
                 }
            }
        }
    });

exports.notifyLikeOnCreate = functions.firestore
    .document('Notifications/{uid}/R/{rId}')
    .onCreate(async (snapshot,context) => {
        const data = snapshot.data();
        var userId = context.params.uid;
        var docId = context.params.rId;
        if(docId != "count"){
                const querySnapshot = fireDb.collection("users")
                .doc(userId).collection('devices')
                .get();

                var tokens = [];
                var platforms = [];

                (await querySnapshot).docs.map((snap) => {
                    tokens.push(snap.data().token);
                    platforms.push(snap.data().platform);
                });

                functions.logger.log("Tokens: ", tokens);
                functions.logger.log("Platforms: ", platforms);

                payload = "";

                for(const index in platforms) {//U+1F525 //U+2764
                    fcm.send({
                      token: tokens[index],
                      data:{
                          click_action:'FLUTTER_NOTIFICATION_CLICK',
                          screen:"like_notification",
                          title:"LitPie | Fresh LitPie \u{1F525}\u{2764} ",
                          body: data.name + ' sent you a LitPie.',
                          sound:"false",
                          vibrate:"false",


                      },
                      // Add APNS (Apple) config
                      apns: {
                        payload: {
                          aps: {
                            contentAvailable: true,

                           },
                        },
                        headers: {
                          "apns-push-type": "background",
                          "apns-priority": "5", // Must be `5` when `contentAvailable` is set to true.
                          "apns-topic": "io.flutter.plugins.firebase.messaging", // bundle identifier
                        },
                      },
                    });
                }
        }
    });

    exports.notifyLikeOnUpdate = functions.firestore
        .document('Notifications/{uid}/R/{rId}')
        .onUpdate(async (snapshot,context) => {
            const data = snapshot.after.data();
            var userId = context.params.uid;
            var docId = context.params.rId;
            if(docId != "count"){
                    const querySnapshot = fireDb.collection("users")
                    .doc(userId).collection('devices')
                    .get();

                    var tokens = [];
                    var platforms = [];

                    (await querySnapshot).docs.map((snap) => {
                        tokens.push(snap.data().token);
                        platforms.push(snap.data().platform);
                    });

                    functions.logger.log("Tokens: ", tokens);
                    functions.logger.log("Platforms: ", platforms);

                    payload = "";

                    for(const index in platforms) {

                        if(data.fresh > 1){
                            fcm.send({
                              token: tokens[index],
                              data:{
                                  title:'LitPie | Fresh LitPie \u{1F525}\u{2764}',
                                  body: data.name + " sent you "+ data.fresh +" LitPie's.",
                                  click_action:'FLUTTER_NOTIFICATION_CLICK',
                                  screen:"like_notification",
                                  sound:"false",
                                  vibrate:"false",
                              },
                              // Add APNS (Apple) config
                              apns: {
                                payload: {
                                  aps: {
                                    contentAvailable: true,

                                   },
                                },
                                headers: {
                                  "apns-push-type": "background",
                                  "apns-priority": "5", // Must be `5` when `contentAvailable` is set to true.
                                  "apns-topic": "io.flutter.plugins.firebase.messaging", // bundle identifier
                                },
                              },
                            });
                        }if(data.fresh == 0){
                             fcm.send({
                               token: tokens[index],
                               data:{
                                   title:'LitPie | Fresh LitPie \u{1F525}\u{2764}',
                                   body: 'Send fresh LitPie to '+ data.name + ' now.',
                                   click_action:'FLUTTER_NOTIFICATION_CLICK',
                                   screen:"like_notification",
                                   sound:"false",
                                   vibrate:"false",
                               },
                               // Add APNS (Apple) config
                               apns: {
                                 payload: {
                                   aps: {
                                     contentAvailable: true,

                                    },
                                 },
                                 headers: {
                                   "apns-push-type": "background",
                                   "apns-priority": "5", // Must be `5` when `contentAvailable` is set to true.
                                   "apns-topic": "io.flutter.plugins.firebase.messaging", // bundle identifier
                                 },
                               },
                             });
                         } else{
                            fcm.send({
                              token: tokens[index],
                              data:{
                                  title:'LitPie | Fresh LitPie \u{1F525}\u{2764}',
                                  body: data.name + ' sent you '+ data.fresh +' LitPie.',
                                  click_action:'FLUTTER_NOTIFICATION_CLICK',
                                  screen:"like_notification",
                                  sound:"false",
                                  vibrate:"false",
                              },
                              // Add APNS (Apple) config
                              apns: {
                                payload: {
                                  aps: {
                                    contentAvailable: true,

                                 },
                                },
                                headers: {
                                  "apns-push-type": "background",
                                  "apns-priority": "5", // Must be `5` when `contentAvailable` is set to true.
                                  "apns-topic": "io.flutter.plugins.firebase.messaging", // bundle identifier
                                },
                              },
                            });
                        }

                    }
            }
        });

exports.notifyMatchesOnCreate = functions.firestore
    .document('Notifications/{uid}/Matches/{mId}')
    .onCreate(async (snapshot,context) => {
        const data = snapshot.data();
        var userId = context.params.uid;
        var docId = context.params.mId;
        if(docId != "count"){
            if(docId == data.currentUser){
                const querySnapshot = fireDb.collection("users")
                    .doc(userId).collection('devices')
                    .get();

                    var tokens = [];
                    var platforms = [];

                    (await querySnapshot).docs.map((snap) => {
                        tokens.push(snap.data().token);
                        platforms.push(snap.data().platform);
                    });

                    functions.logger.log("Tokens: ", tokens);
                    functions.logger.log("Platforms: ", platforms);

                    payload = "";

                    for(const index in platforms) {
                        fcm.send({
                          token: tokens[index],
                          data:{
                              click_action:'FLUTTER_NOTIFICATION_CLICK',
                              screen:"match_notification",
                              title:'LitPie | New Match \u{1F48C}',
                              body: 'You got a match with ' + data.userName + '.',
                              sound:"true",
                              vibrate:"true",
                          },
                          // Add APNS (Apple) config
                          apns: {
                            payload: {
                              aps: {
                                contentAvailable: true,
                               },
                            },
                            headers: {
                              "apns-push-type": "background",
                              "apns-priority": "5", // Must be `5` when `contentAvailable` is set to true.
                              "apns-topic": "io.flutter.plugins.firebase.messaging", // bundle identifier
                            },
                          },
                        });
                    }
            }
        }
    });

exports.notifyChatOnCreate = functions.database.ref('/chats/{chatId}/messages/{msgId}')
    .onCreate(async (snapshot, context) => {
        const chatDetail = snapshot.val();
        functions.logger.log("Receiver Id: ", chatDetail.receiverId);
        const querySnapshot = fireDb.collection("users")
          .doc(chatDetail.receiverId).collection('devices')
          .get();

        var tokens = [];
        var platforms = [];

        (await querySnapshot).docs.map((snap) => {
            tokens.push(snap.data().token);
            platforms.push(snap.data().platform);
        });

        functions.logger.log("Tokens: ", tokens);
        functions.logger.log("Platforms: ", platforms);

        payload = "";

        for(const index in platforms) {
            fcm.send({
              token: tokens[index],

              data:{// U+1F4ED
                  title:'LitPie | New Message \u{1F4ED}',
                  body: chatDetail.senderName + ' : '+ chatDetail.text,
                  click_action:'FLUTTER_NOTIFICATION_CLICK',
                  screen:"chat_notification",
                  sound:"true",
                  vibrate:"true",
                  },
              // Add APNS (Apple) config
              apns: {
                payload: {
                  aps: {
                    contentAvailable: true,

              },
              },
                headers: {
                  "apns-push-type": "background",
                  "apns-priority": "5", // Must be `5` when `contentAvailable` is set to true.
                  "apns-topic": "io.flutter.plugins.firebase.messaging", // bundle identifier
                },
              },
            });
        }
    });

exports.notifyWaveOnCreate = functions.firestore
    .document('users/{uid}/onlineWave/{mId}')
    .onCreate(async (snapshot,context) => {
        const data = snapshot.data();
        if(data.request == "received"){
            var userId = context.params.uid;
            var docId = context.params.mId;
            if(docId != "count"){
                const querySnapshot = fireDb.collection("users")
                    .doc(userId).collection('devices')
                    .get();

                    var tokens = [];
                    var platforms = [];

                    (await querySnapshot).docs.map((snap) => {
                        tokens.push(snap.data().token);
                        platforms.push(snap.data().platform);
                    });

                    functions.logger.log("Tokens: ", tokens);
                    functions.logger.log("Platforms: ", platforms);

                    payload = "";

                    for(const index in platforms) {
                        fcm.send({
                          token: tokens[index],
                          data:{
                              click_action:'FLUTTER_NOTIFICATION_CLICK',
                              screen:"wave_notification",
                              title:'LitPie | New Wave \u{1F44B}',
                              body: data.userName + ' Waved You',
                              sound:"false",
                              vibrate:"true",
                          },
                          // Add APNS (Apple) config
                          apns: {
                            payload: {
                              aps: {
                                contentAvailable: true,
                               },
                            },
                            headers: {
                              "apns-push-type": "background",
                              "apns-priority": "5", // Must be `5` when `contentAvailable` is set to true.
                              "apns-topic": "io.flutter.plugins.firebase.messaging", // bundle identifier
                            },
                          },
                        });
                    }
            }
        }

    });

exports.notifyWaveOnUpdate = functions.firestore
    .document('users/{uid}/onlineWave/{mId}')
    .onUpdate(async (snapshot,context) => {
        const data = snapshot.after.data();
        if(data.request == "sent" && data.isRead == true){
            var userId = context.params.uid;
            var docId = context.params.mId;
            if(docId != "count"){
                const querySnapshot = fireDb.collection("users")
                    .doc(userId).collection('devices')
                    .get();

                    var tokens = [];
                    var platforms = [];

                    (await querySnapshot).docs.map((snap) => {
                        tokens.push(snap.data().token);
                        platforms.push(snap.data().platform);
                    });

                    functions.logger.log("Tokens: ", tokens);
                    functions.logger.log("Platforms: ", platforms);

                    payload = "";

                    for(const index in platforms) {
                        fcm.send({
                          token: tokens[index],
                          data:{
                              click_action:'FLUTTER_NOTIFICATION_CLICK',
                              screen:"wave_notification",
                              title:'LitPie | Wave Back \u{1F44B} ',
                              body: data.userName + ' Waved Back To You',
                              sound:"false",
                              vibrate:"true",
                          },
                          // Add APNS (Apple) config
                          apns: {
                            payload: {
                              aps: {
                                contentAvailable: true,
                               },
                            },
                            headers: {
                              "apns-push-type": "background",
                              "apns-priority": "5", // Must be `5` when `contentAvailable` is set to true.
                              "apns-topic": "io.flutter.plugins.firebase.messaging", // bundle identifier
                            },
                          },
                        });
                    }
            }
        }

    });