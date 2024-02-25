/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// import { onRequest } from 'firebase-functions/v2/https'
import * as admin from 'firebase-admin'
import * as functions from 'firebase-functions'

admin.initializeApp()

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// 監聽影片創建事件, 當影片創建時觸發此方法
export const onVideoCreated = functions
  .runWith({ memory: '512MB' })
  .firestore.document('videos/{videoId}')
  .onCreate(async (snapshot, context) => {
    try {
      const spawn = require('child-process-promise').spawn

      const video = snapshot.data()

      // 產出影片縮圖
      await spawn('ffmpeg', [
        '-i',
        video.fileUrl,
        '-ss',
        // 從影片的第一秒開始截圖
        '00:00:01.000',
        '-vframes',
        '1',
        '-vf',
        // 寬度 150，高度等比例縮放
        'scale=150:-1',
        `/tmp/${snapshot.id}.jpg`
      ])

      // 圖片儲存到 Storage
      const storage = admin.storage()
      const [file, _] = await storage
        .bucket()
        .upload(`/tmp/${snapshot.id}.jpg`, {
          destination: `thumbnails/${snapshot.id}.jpg`
        })

      // 將上傳的文件設為公開
      await file.makePublic()

      // 將縮圖的 URL 更新到 Firestore 中的 video 文件
      await snapshot.ref.update({ thumbnailUrl: file.publicUrl() })

      const db = admin.firestore()
      // 同步將縮圖網址更新到創建者 user 資料底下, 方便快速取得
      // /videos/123 同步到 /users/:userId/videos/123/thumbnailUrl
      await db
        .collection('users')
        .doc(video.creatorUid)
        .collection('videos')
        .doc(snapshot.id)
        .set({
          thumbnailUrl: file.publicUrl(),
          videoId: snapshot.id
        })
    } catch (error) {
      console.log('error: ', error)
    }
  })
