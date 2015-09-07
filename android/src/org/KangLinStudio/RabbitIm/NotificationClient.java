/*
* android平台消息通知java实现  
*/

package org.KangLinStudio.RabbitIm;

import android.app.Notification;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.app.PendingIntent;
import android.util.Log;
//import android.graphics.Bitmap;
//import android.graphics.BitmapFactory;

public class NotificationClient 
    extends org.qtproject.qt5.android.bindings.QtActivity
{
    private static final String TAG = "NotificationClient";
    private static NotificationManager m_notificationManager = null;
    private static Notification.Builder m_builder = null;
    private static NotificationClient m_instance = null;
    private static final int m_nCount = 0;
    
    public NotificationClient()
    {
        Log.d(TAG, "NotificationClient");
        m_instance = this;
    }

    public static void notify(String szMessage, String szTitle)
    {
        Log.d(TAG, "notify:message:" + szMessage + ":title:" + szTitle);
      if (null == m_notificationManager) {
           m_notificationManager = 
                (NotificationManager)m_instance.getSystemService(
                Context.NOTIFICATION_SERVICE);
           m_builder = new Notification.Builder(m_instance);
           if(null == m_builder)
               Log.e(TAG, "m_builder is null");
           m_builder.setSmallIcon(R.drawable.icon);
           //Bitmap bitmap = BitmapFactory.decodeResource(this.getResources(), R.drawable.icon);
           // 设置通知栏中的通知下拉后显示的图标，图片格式为bitmap型  
           //m_builder.setLargeIcon(bitmap); 
           // 设置时间发生时间  
           m_builder.setWhen(System.currentTimeMillis()); 
           // 当通知被用户点击时，通知将被清除（好象要设置intent后才会有效）   
           m_builder.setAutoCancel(true);
           // 实例化Intent  
           Intent intent = new Intent(m_instance, NotificationClient.class);
           // 获取PendingIntent  
           PendingIntent pi = PendingIntent.getActivity(m_instance, 0, intent, 0);
           m_builder.setContentIntent(pi); // 设置点击通知将要启动的Inent  
       }

       m_builder.setTicker(szTitle + " " + szMessage); // 在状态栏上提示的文字  
       m_builder.setContentTitle(szTitle); // 在下拉栏中提示的标题  
       m_builder.setContentText(szMessage); // 在下拉栏中提示的文字  
       // m_nCount是下拉栏提示ID，每个ID对应一个下拉提示栏  
       if(null != m_notificationManager)
           m_notificationManager.notify(m_nCount, m_builder.build());
       else
           Log.e(TAG, "m_notificationManager is null");
   }

   public static void CancelAll()
   {
       if(null != m_notificationManager)
           m_notificationManager.cancelAll();
   }
}
