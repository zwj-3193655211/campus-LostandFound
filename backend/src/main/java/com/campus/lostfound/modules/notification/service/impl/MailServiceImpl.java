package com.campus.lostfound.modules.notification.service.impl;

import com.campus.lostfound.modules.item.entity.Item;
import com.campus.lostfound.modules.match.entity.Match;
import com.campus.lostfound.modules.notification.service.MailService;
import jakarta.mail.Authenticator;
import jakarta.mail.BodyPart;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeBodyPart;
import jakarta.mail.internet.MimeMessage;
import jakarta.mail.internet.MimeMultipart;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Properties;

@Service
public class MailServiceImpl implements MailService {

    private static final Logger log = LoggerFactory.getLogger(MailServiceImpl.class);

    @Value("${spring.mail.username:}")
    private String fromEmail;

    @Value("${spring.mail.password:}")
    private String authCode;

    @Value("${spring.mail.host:smtp.163.com}")
    private String smtpHost;

    @Value("${spring.mail.port:25}")
    private int smtpPort;

    @Value("${app.base-url:http://localhost:8080}")
    private String baseUrl;

    @Override
    public void sendMatchNotificationEmail(
            String userEmail,
            String userName,
            Item item,
            Item matchedItem,
            Match match
    ) {
        try {
            sendHtmlEmail(
                    userEmail,
                    "【校园失物招领】匹配提醒 - 您丢失的物品可能找到了！",
                    buildMatchEmailHtml(userName, item, matchedItem, match)
            );
            log.info("匹配通知邮件已发送至: {}", userEmail);
        } catch (Exception e) {
            log.error("发送匹配通知邮件失败: {}", e.getMessage(), e);
        }
    }

    @Override
    public void sendVerificationEmail(
            String userEmail,
            String userName,
            Item item,
            boolean approved,
            String reason
    ) {
        try {
            String subject = approved ?
                    "【校园失物招领】审核通过 - 您的物品已发布" :
                    "【校园失物招领】审核反馈 - 请及时处理";

            sendHtmlEmail(
                    userEmail,
                    subject,
                    buildVerificationEmailHtml(userName, item, approved, reason)
            );
            log.info("审核通知邮件已发送至: {}", userEmail);
        } catch (Exception e) {
            log.error("发送审核通知邮件失败: {}", e.getMessage(), e);
        }
    }

    @Override
    public boolean sendTestEmail(String userEmail) {
        try {
            sendHtmlEmail(userEmail, "【校园失物招领】测试邮件", "<p>这是一封测试邮件</p>");
            return true;
        } catch (Exception e) {
            log.error("发送测试邮件失败: {}", e.getMessage(), e);
            return false;
        }
    }

    @Override
    public void sendSimpleEmail(String userEmail, String subject, String content) {
        try {
            sendHtmlEmail(userEmail, subject, "<p>" + escapeHtml(content) + "</p>");
            log.info("简单通知邮件已发送至: {}", userEmail);
        } catch (Exception e) {
            log.error("发送简单通知邮件失败: {}", e.getMessage(), e);
        }
    }

    private Session createMailSession() {
        Properties props = new Properties();
        props.put("mail.smtp.host", smtpHost);
        props.put("mail.smtp.port", smtpPort);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.timeout", "30000");
        props.put("mail.smtp.connectiontimeout", "30000");
        
        if (smtpPort == 465) {
            props.put("mail.smtp.ssl.enable", "true");
            props.put("mail.smtp.socketFactory.port", smtpPort);
            props.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
        } else {
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.starttls.required", "true");
        }

        return Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, authCode);
            }
        });
    }

    private void sendHtmlEmail(String to, String subject, String htmlContent) throws Exception {
        Session session = createMailSession();

        MimeMessage message = new MimeMessage(session);
        message.setFrom(new InternetAddress(fromEmail, "校园失物招领平台"));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        message.setSubject(subject, "UTF-8");

        MimeMultipart multipart = new MimeMultipart("alternative");
        BodyPart htmlPart = new MimeBodyPart();
        htmlPart.setContent(htmlContent, "text/html;charset=UTF-8");
        multipart.addBodyPart(htmlPart);

        message.setContent(multipart);
        Transport.send(message);
    }

    private String buildMatchEmailHtml(String userName, Item item, Item matchedItem, Match match) {
        int scorePercent = match.getScore().multiply(java.math.BigDecimal.valueOf(100)).intValue();

        return """
            <!DOCTYPE html>
            <html>
            <head><meta charset="UTF-8"></head>
            <body style="font-family:'Microsoft YaHei',Arial,sans-serif;background:#f5f5f5;padding:20px;">
                <div style="max-width:600px;margin:0 auto;background:white;border-radius:10px;overflow:hidden;">
                    <div style="background:linear-gradient(135deg,#667eea,#764ba2);color:white;padding:20px;text-align:center;">
                        <h1>校园失物招领平台</h1>
                        <p>智能匹配提醒</p>
                    </div>
                    <div style="padding:20px;">
                        <p>亲爱的<strong>%s</strong>：</p>
                        <p>我们发现您发布的「%s」与一条失物招领信息高度匹配！</p>
                        <div style="background:#e8f5e9;border:2px solid #4caf50;border-radius:8px;padding:15px;text-align:center;margin:15px 0;">
                            <div style="font-size:32px;font-weight:bold;color:#2e7d32;">%d%%</div>
                            <div>匹配度</div>
                        </div>
                        <div style="background:#f9f9f9;border-radius:8px;padding:15px;margin:10px 0;">
                            <h3>您发布的物品</h3>
                            <p>标题：%s</p>
                            <p>类别：%s</p>
                            <p>描述：%s</p>
                        </div>
                        <div style="background:#f9f9f9;border-radius:8px;padding:15px;margin:10px 0;">
                            <h3>匹配到的物品</h3>
                            <p>标题：%s</p>
                            <p>类别：%s</p>
                            <p>描述：%s</p>
                        </div>
                        <p style="text-align:center;margin-top:20px;">
                            <a href="%s" style="display:inline-block;background:#667eea;color:white;padding:12px 24px;text-decoration:none;border-radius:5px;">查看详情</a>
                        </p>
                    </div>
                    <div style="background:#f5f5f5;padding:15px;text-align:center;color:#999;font-size:12px;">
                        © 2026 校园失物招领平台
                    </div>
                </div>
            </body>
            </html>
            """.formatted(
                userName,
                item.getTitle(),
                scorePercent,
                escapeHtml(item.getTitle()),
                escapeHtml(item.getCategory()),
                escapeHtml(item.getDescription() != null ? item.getDescription() : "-"),
                escapeHtml(matchedItem.getTitle()),
                escapeHtml(matchedItem.getCategory()),
                escapeHtml(matchedItem.getDescription() != null ? matchedItem.getDescription() : "-"),
                baseUrl
            );
    }

    private String buildVerificationEmailHtml(String userName, Item item, boolean approved, String reason) {
        String statusText = approved ? "审核通过" : "审核未通过";
        String statusColor = approved ? "#4caf50" : "#f44336";

        return """
            <!DOCTYPE html>
            <html>
            <head><meta charset="UTF-8"></head>
            <body style="font-family:'Microsoft YaHei',Arial,sans-serif;background:#f5f5f5;padding:20px;">
                <div style="max-width:600px;margin:0 auto;background:white;border-radius:10px;overflow:hidden;">
                    <div style="background:linear-gradient(135deg,#667eea,#764ba2);color:white;padding:20px;text-align:center;">
                        <h1>校园失物招领平台</h1>
                        <p>审核结果通知</p>
                    </div>
                    <div style="padding:20px;">
                        <p>亲爱的<strong>%s</strong>：</p>
                        <p>您的物品发布审核结果如下：</p>
                        <div style="text-align:center;margin:20px 0;">
                            <span style="background:%s;color:white;padding:10px 20px;border-radius:5px;font-weight:bold;">%s</span>
                        </div>
                        <div style="background:#f9f9f9;border-radius:8px;padding:15px;margin:15px 0;">
                            <p><strong>标题：</strong>%s</p>
                            <p><strong>类别：</strong>%s</p>
                        </div>
            %s
                    </div>
                    <div style="background:#f5f5f5;padding:15px;text-align:center;color:#999;font-size:12px;">
                        © 2026 校园失物招领平台
                    </div>
                </div>
            </body>
            </html>
            """.formatted(
                userName,
                statusColor,
                statusText,
                escapeHtml(item.getTitle()),
                escapeHtml(item.getCategory()),
                reason != null ? "<p style=\"background:#ffebee;border-left:4px solid #f44336;padding:10px;\"><strong>原因：</strong>" + escapeHtml(reason) + "</p>" : ""
            );
    }

    private String escapeHtml(String text) {
        if (text == null) return "";
        return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
}
