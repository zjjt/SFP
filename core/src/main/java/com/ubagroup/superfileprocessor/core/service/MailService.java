package com.ubagroup.superfileprocessor.core.service;

import org.apache.commons.lang3.StringEscapeUtils;
import org.springframework.stereotype.Service;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.*;
import java.net.*;
import java.util.*;

@Service
public class MailService {
    public  boolean sendMail(String subject, List<String> to, String from, List<String> cci,  List<File> attachments, String body,String smtpHost) throws IOException {
        String actionSoap ="";
        String bodySoap = "";
        String tagSoap= "";
         bodySoap=_buildFinalSoapEnveloppe(attachments.isEmpty()?false:true,from,_addRecipientsSoap(to,attachments.isEmpty()?false:true),_addRecipientsSoapCC(cci,attachments.isEmpty()?false:true),subject,_buildMail(body),_addFilesSoap(attachments));
        //System.out.println("body du soap\n"+bodySoap);
        if(attachments.isEmpty()){
            //
            actionSoap = "http://tempuri.org/SendMailToMany";
            tagSoap = "SendMailToManyResult";
        }else{
            actionSoap = "http://tempuri.org/SendMailAttachment";
            tagSoap = "SendMailAttachmentResult";
        }
        var params=URLEncoder.encode(bodySoap,"UTF-8");
        String postData="e="+params;
        URL url=new URL(smtpHost+"/service.asmx");
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("POST");
        con.setDoInput(true);
        con.setDoOutput(true);
        con.setRequestProperty("Content-Type", "text/xml;charset=UTF-8");
        con.setRequestProperty("SOAPAction", actionSoap);
        //con.setRequestProperty("Content-Length",String.valueOf(postData.length()));
        OutputStream os = con.getOutputStream();
        BufferedWriter writer = new BufferedWriter(
                new OutputStreamWriter(os, "UTF-8"));
        writer.write(bodySoap);
        writer.flush();
        writer.close();
        os.close();
        int status = con.getResponseCode();
        System.out.println("status of mail sending is "+status+"\nerr:"+con.getResponseMessage());

        if (status > 299) {
            var response=con.getResponseMessage();
         System.out.println(response);
        } else {
            Reader streamReader = new InputStreamReader(con.getInputStream());
            BufferedReader in = new BufferedReader(
                    streamReader);
            String inputLine;
            StringBuffer response = new StringBuffer();
            while ((inputLine = in.readLine()) != null) {
                response.append(inputLine);
            }
            in.close();
            //System.out.println(response);
            Document xmlDoc=_convertResponseToXMLDocument(response);
            String val = xmlDoc.getElementsByTagName(tagSoap).item(0).getTextContent();
            System.out.println("VAL ==> :"+val);
            if(val != null && val.trim().equalsIgnoreCase("true")) return true;
        }



        return false;
    }

    private  String _getPostDataString(HashMap<String, String> params) throws UnsupportedEncodingException{
        StringBuilder result = new StringBuilder();
        boolean first = true;
        for(Map.Entry<String, String> entry : params.entrySet()){
            if (first)
                first = false;
            else
                result.append("&");

            result.append(URLEncoder.encode(entry.getKey(), "UTF-8"));
            result.append("=");
            result.append(URLEncoder.encode(entry.getValue(), "UTF-8"));
        }

        return result.toString();
    }

    private  Document _convertResponseToXMLDocument(StringBuffer response)
    {
        //Parser that produces DOM object trees from XML content
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();

        //API to obtain DOM Document instance
        DocumentBuilder builder = null;
        try
        {
            //Create DocumentBuilder with default configuration
            builder = factory.newDocumentBuilder();

            //Parse the content to Document object
            Document doc = builder.parse(new InputSource(new StringReader(response.toString())));
            return doc;
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
        return null;
    }

    private   String _buildFinalSoapEnveloppe(boolean withFile, String sender, String recipient, String cc,String subject, String message,String files) {
        String soapWithFile ="<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\">\r\n" +
                "   <soapenv:Header/>\r\n" +
                "   <soapenv:Body>\r\n" +
                "      <tem:SendMailAttachment>\r\n" +
                "         <!--Optional:-->\r\n" +
                "         <tem:fileAttach>\r\n" +
                "           {{files}}"+
                "         </tem:fileAttach>\r\n" +
                "         <!--Optional:-->\r\n" +
                "         <tem:recipient>{{recipient}}</tem:recipient>\r\n" +
                "         <!--Optional:-->\r\n" +
                "         <tem:sender>{{sender}}</tem:sender>\r\n" +
                "         <!--Optional:-->\r\n" +
                "         <tem:subject>{{subject}}</tem:subject>\r\n" +
                "         <!--Optional:-->\r\n" +
                "         <tem:body><![CDATA[{{message}}]]></tem:body>\r\n" +
                "         <!--Optional:-->\r\n" +
                "         <tem:CopyP>{{cc}}</tem:CopyP>\r\n" +
                "      </tem:SendMailAttachment>\r\n" +
                "   </soapenv:Body>\r\n" +
                "</soapenv:Envelope>";

        String soapToMany = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tem=\"http://tempuri.org/\">\r\n" +
                "   <soapenv:Header/>\r\n" +
                "   <soapenv:Body>\r\n" +
                "      <tem:SendMailToMany>\r\n" +
                "         <!--Optional:-->\r\n" +
                "         <tem:recipients>{{recipient}}</tem:recipients>\r\n" +
                "         <!--Optional:-->\r\n" +
                "         <tem:sender>{{sender}}</tem:sender>\r\n" +
                "         <!--Optional:-->\r\n" +
                "         <tem:subject>{{subject}}</tem:subject>\r\n" +
                "         <!--Optional:-->\r\n" +
                "         <tem:body><![CDATA[{{message}}]]></tem:body>\r\n" +
                "         <!--Optional:-->\r\n" +
                "         <tem:CCs>{{cc}}</tem:CCs>\r\n" +
                "      </tem:SendMailToMany>\r\n" +
                "   </soapenv:Body>\r\n" +
                "</soapenv:Envelope>";
        String soap="";
        if(withFile){
            soap=soapWithFile;
        }else{
            soap=soapToMany;
        }


        return soap.replace("{{sender}}", sender).
                replace("{{recipient}}",recipient).
                replace("{{cc}}",cc).replace("{{subject}}", subject).
                replace("{{message}}",message).
                replace("{{files}}",files);
    }

    private  String _addRecipientsSoap(List<String> recipients,boolean withFiles) {
        String strz ="";
        for(String str : recipients) {
            if(withFiles){
                strz+=StringEscapeUtils.escapeXml(str);
            }else{
                strz+="<tem:string>"+StringEscapeUtils.escapeXml(str)+"</tem:string>\r\n";
            }
        }		return strz;
    }
    private  String _addRecipientsSoapCC(List<String> recipients,boolean withFiles) {
        String strz ="";
        for(String str : recipients) {
            if(withFiles){
                strz+="<tem:string>"+StringEscapeUtils.escapeXml(str)+"</tem:string>\r\n";
            }else{
                strz+="<tem:string>"+StringEscapeUtils.escapeXml(str)+"</tem:string>\r\n";
            }
        }		return strz;
    }
    private  String _addFilesSoap(List<File> files) throws IOException {
        String str = "";
        if(files.size()>0) {
            for(int j=0 ;j<files.size();j++) {
                str+="<tem:FileAttach>\r\n" +
                        "               <!--Optional:-->\r\n" +
                        "               <tem:FileByte>"+ StringEscapeUtils.escapeXml(_encodeFileToBase64Binary(files.get(j)))+"</tem:FileByte>\r\n" +
                        "               <!--Optional:-->\r\n" +
                        "               <tem:FileName>"+StringEscapeUtils.escapeXml(files.get(j).getName())+"</tem:FileName>\r\n" +
                        "            </tem:FileAttach>\r\n" +
                        "";
            }
        }
        return str;
    }

    private  String _encodeFileToBase64Binary(File file) throws IOException {
        byte[] bytes = _loadFile(file);
        byte[] encoded = Base64.getEncoder().encode(bytes);
        String encodedString = new String(encoded);
        return encodedString;
    }

    private  byte[] _loadFile(File file) throws IOException {
        InputStream is = new FileInputStream(file);
        long length = file.length();
        if (length > Integer.MAX_VALUE) {
            is.close();
            throw new IOException("file too large...");

        }
        byte[] bytes = new byte[(int)length];

        int offset = 0;
        int numRead = 0;
        while (offset < bytes.length
                && (numRead=is.read(bytes, offset, bytes.length-offset)) >= 0) {
            offset += numRead;
        }

        if (offset < bytes.length) {
            is.close();
            throw new IOException("Could not completely read file "+file.getName());
        }

        is.close();
        return bytes;
    }

    private  String _buildMail(String body){
        String html="<!DOCTYPE html>\r\n" +
                "<html lang=\"fr\" xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:v=\"urn:schemas-microsoft-com:vml\" xmlns:o=\"urn:schemas-microsoft-com:office:office\">\r\n" +
                "<head>\r\n" +
                "    <meta charset=\"utf-8\"> <!-- utf-8 works for most cases -->\r\n" +
                "    <meta name=\"viewport\" content=\"width=device-width\"> <!-- Forcing initial-scale shouldn't be necessary -->\r\n" +
                "    <meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"> <!-- Use the latest (edge) version of IE rendering engine -->\r\n" +
                "    <meta name=\"x-apple-disable-message-reformatting\">  <!-- Disable auto-scale in iOS 10 Mail entirely -->\r\n" +
                "    <title></title> <!-- The title tag shows in email notifications, like Android 4.4. -->\r\n" +
                "\r\n" +
                "    <!-- Web Font / @font-face : BEGIN -->\r\n" +
                "    <!-- NOTE: If web fonts are not required, lines 10 - 27 can be safely removed. -->\r\n" +
                "\r\n" +
                "    <!-- Desktop Outlook chokes on web font references and defaults to Times New Roman, so we force a safe fallback font. -->\r\n" +
                "    <!--[if mso]>\r\n" +
                "        <style>\r\n" +
                "            * {\r\n" +
                "                font-family: sans-serif !important;\r\n" +
                "            }\r\n" +
                "        </style>\r\n" +
                "    <![endif]-->\r\n" +
                "\r\n" +
                "    <!-- All other clients get the webfont reference; some will render the font and others will silently fail to the fallbacks. More on that here: http://stylecampaign.com/blog/2015/02/webfont-support-in-email/ -->\r\n" +
                "    <!--[if !mso]><!-->\r\n" +
                "    <!-- insert web font reference, eg: <link href='https://fonts.googleapis.com/css?family=Roboto:400,700' rel='stylesheet' type='text/css'> -->\r\n" +
                "    <!--<![endif]-->\r\n" +
                "\r\n" +
                "    <!-- Web Font / @font-face : END -->\r\n" +
                "\r\n" +
                "    <!-- CSS Reset : BEGIN -->\r\n" +
                "    <style>\r\n" +
                "\r\n" +
                "        /* What it does: Remove spaces around the email design added by some email clients. */\r\n" +
                "        /* Beware: It can remove the padding / margin and add a background color to the compose a reply window. */\r\n" +
                "        html,\r\n" +
                "        body {\r\n" +
                "            margin: 0 auto !important;\r\n" +
                "            padding: 0 !important;\r\n" +
                "            height: 100% !important;\r\n" +
                "            width: 100% !important;\r\n" +
                "        }\r\n" +
                "\r\n" +
                "        /* What it does: Stops email clients resizing small text. */\r\n" +
                "        * {\r\n" +
                "            -ms-text-size-adjust: 100%;\r\n" +
                "            -webkit-text-size-adjust: 100%;\r\n" +
                "        }\r\n" +
                "\r\n" +
                "        /* What it does: Centers email on Android 4.4 */\r\n" +
                "        div[style*=\"margin: 16px 0\"] {\r\n" +
                "            margin: 0 !important;\r\n" +
                "        }\r\n" +
                "\r\n" +
                "        /* What it does: Stops Outlook from adding extra spacing to tables. */\r\n" +
                "        table,\r\n" +
                "        td {\r\n" +
                "            mso-table-lspace: 0pt !important;\r\n" +
                "            mso-table-rspace: 0pt !important;\r\n" +
                "        }\r\n" +
                "\r\n" +
                "        /* What it does: Fixes webkit padding issue. */\r\n" +
                "        table {\r\n" +
                "            border-spacing: 0 !important;\r\n" +
                "            border-collapse: collapse !important;\r\n" +
                "            table-layout: fixed !important;\r\n" +
                "            margin: 0 auto !important;\r\n" +
                "        }\r\n" +
                "\r\n" +
                "        /* What it does: Prevents Windows 10 Mail from underlining links despite inline CSS. Styles for underlined links should be inline. */\r\n" +
                "        a {\r\n" +
                "            text-decoration: none;\r\n" +
                "        }\r\n" +
                "\r\n" +
                "        /* What it does: Uses a better rendering method when resizing images in IE. */\r\n" +
                "        img {\r\n" +
                "            -ms-interpolation-mode:bicubic;\r\n" +
                "        }\r\n" +
                "\r\n" +
                "        /* What it does: A work-around for email clients meddling in triggered links. */\r\n" +
                "        *[x-apple-data-detectors],  /* iOS */\r\n" +
                "        .unstyle-auto-detected-links *,\r\n" +
                "        .aBn {\r\n" +
                "            border-bottom: 0 !important;\r\n" +
                "            cursor: default !important;\r\n" +
                "            color: inherit !important;\r\n" +
                "            text-decoration: none !important;\r\n" +
                "            font-size: inherit !important;\r\n" +
                "            font-family: inherit !important;\r\n" +
                "            font-weight: inherit !important;\r\n" +
                "            line-height: inherit !important;\r\n" +
                "        }\r\n" +
                "\r\n" +
                "        /* What it does: Prevents Gmail from changing the text color in conversation threads. */\r\n" +
                "        .im {\r\n" +
                "            color: inherit !important;\r\n" +
                "        }\r\n" +
                "\r\n" +
                "        /* What it does: Prevents Gmail from displaying a download button on large, non-linked images. */\r\n" +
                "        .a6S {\r\n" +
                "           display: none !important;\r\n" +
                "           opacity: 0.01 !important;\r\n" +
                "		}\r\n" +
                "		/* If the above doesn't work, add a .g-img class to any image in question. */\r\n" +
                "		img.g-img + div {\r\n" +
                "		   display: none !important;\r\n" +
                "		}\r\n" +
                "\r\n" +
                "        /* What it does: Removes right gutter in Gmail iOS app: https://github.com/TedGoas/Cerberus/issues/89  */\r\n" +
                "        /* Create one of these media queries for each additional viewport size you'd like to fix */\r\n" +
                "\r\n" +
                "        /* iPhone 4, 4S, 5, 5S, 5C, and 5SE */\r\n" +
                "        @media only screen and (min-device-width: 320px) and (max-device-width: 374px) {\r\n" +
                "            u ~ div .email-container {\r\n" +
                "                min-width: 320px !important;\r\n" +
                "            }\r\n" +
                "        }\r\n" +
                "        /* iPhone 6, 6S, 7, 8, and X */\r\n" +
                "        @media only screen and (min-device-width: 375px) and (max-device-width: 413px) {\r\n" +
                "            u ~ div .email-container {\r\n" +
                "                min-width: 375px !important;\r\n" +
                "            }\r\n" +
                "        }\r\n" +
                "        /* iPhone 6+, 7+, and 8+ */\r\n" +
                "        @media only screen and (min-device-width: 414px) {\r\n" +
                "            u ~ div .email-container {\r\n" +
                "                min-width: 414px !important;\r\n" +
                "            }\r\n" +
                "        }\r\n" +
                "\r\n" +
                "    </style>\r\n" +
                "\r\n" +
                "    <!-- What it does: Makes background images in 72ppi Outlook render at correct size. -->\r\n" +
                "    <!--[if gte mso 9]>\r\n" +
                "    <xml>\r\n" +
                "        <o:OfficeDocumentSettings>\r\n" +
                "            <o:AllowPNG/>\r\n" +
                "            <o:PixelsPerInch>96</o:PixelsPerInch>\r\n" +
                "        </o:OfficeDocumentSettings>\r\n" +
                "    </xml>\r\n" +
                "    <![endif]-->\r\n" +
                "\r\n" +
                "    <!-- CSS Reset : END -->\r\n" +
                "\r\n" +
                "    <!-- Progressive Enhancements : BEGIN -->\r\n" +
                "    <style>\r\n" +
                "\r\n" +
                "        /* What it does: Hover styles for buttons */\r\n" +
                "        .button-td,\r\n" +
                "        .button-a {\r\n" +
                "            transition: all 100ms ease-in;\r\n" +
                "        }\r\n" +
                "	    .button-td-primary:hover,\r\n" +
                "	    .button-a-primary:hover {\r\n" +
                "	        background: #555555 !important;\r\n" +
                "	        border-color: #555555 !important;\r\n" +
                "	    }\r\n" +
                "\r\n" +
                "        /* Media Queries */\r\n" +
                "        @media screen and (max-width: 600px) {\r\n" +
                "\r\n" +
                "            .email-container {\r\n" +
                "                width: 100% !important;\r\n" +
                "                margin: auto !important;\r\n" +
                "            }\r\n" +
                "\r\n" +
                "            /* What it does: Forces table cells into full-width rows. */\r\n" +
                "            .stack-column,\r\n" +
                "            .stack-column-center {\r\n" +
                "                display: block !important;\r\n" +
                "                width: 100% !important;\r\n" +
                "                max-width: 100% !important;\r\n" +
                "                direction: ltr !important;\r\n" +
                "            }\r\n" +
                "            /* And center justify these ones. */\r\n" +
                "            .stack-column-center {\r\n" +
                "                text-align: center !important;\r\n" +
                "            }\r\n" +
                "\r\n" +
                "            /* What it does: Generic utility class for centering. Useful for images, buttons, and nested tables. */\r\n" +
                "            .center-on-narrow {\r\n" +
                "                text-align: center !important;\r\n" +
                "                display: block !important;\r\n" +
                "                margin-left: auto !important;\r\n" +
                "                margin-right: auto !important;\r\n" +
                "                float: none !important;\r\n" +
                "            }\r\n" +
                "            table.center-on-narrow {\r\n" +
                "                display: inline-block !important;\r\n" +
                "            }\r\n" +
                "\r\n" +
                "            /* What it does: Adjust typography on small screens to improve readability */\r\n" +
                "            .email-container p {\r\n" +
                "                font-size: 17px !important;\r\n" +
                "            }\r\n" +
                "        }\r\n" +
                "\r\n" +
                "    </style>\r\n" +
                "    <!-- Progressive Enhancements : END -->\r\n" +
                "\r\n" +
                "</head>\r\n" +
                "<!--\r\n" +
                "	The email background color (#222222) is defined in three places:\r\n" +
                "	1. body tag: for most email clients\r\n" +
                "	2. center tag: for Gmail and Inbox mobile apps and web versions of Gmail, GSuite, Inbox, Yahoo, AOL, Libero, Comcast, freenet, Mail.ru, Orange.fr\r\n" +
                "	3. mso conditional: For Windows 10 Mail\r\n" +
                "-->\r\n" +
                "<!--<body width=\"100%\" style=\"margin: 0; padding: 0 !important; mso-line-height-rule: exactly; background-color: #222222;\"> -->\r\n" +
                "<body width=\"100%\" style=\"margin: 0; padding: 0 !important; mso-line-height-rule: exactly; background-color: #ffffff;\">\r\n" +
                "	<!--<center style=\"width: 100%; background-color: #222222;\">-->\r\n" +
                "	<center style=\"width: 100%; background-color: #ffffff;\">\r\n" +
                "    <!--[if mso | IE]>\r\n" +
                "    <table role=\"presentation\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" style=\"background-color: #222222;\">\r\n" +
                "    <tr>\r\n" +
                "    <td>\r\n" +
                "    <![endif]-->\r\n" +
                "\r\n" +
                "        <!-- Visually Hidden Preheader Text : BEGIN -->\r\n" +
                "        <!--<div style=\"display: none; font-size: 1px; line-height: 1px; max-height: 0px; max-width: 0px; opacity: 0; overflow: hidden; mso-hide: all; font-family: sans-serif;\">\r\n" +
                "            (Optional) This text will appear in the inbox preview, but not the email body. It can be used to supplement the email subject line or even summarize the email's contents. Extended text preheaders (~490 characters) seems like a better UX for anyone using a screenreader or voice-command apps like Siri to dictate the contents of an email. If this text is not included, email clients will automatically populate it using the text (including image alt text) at the start of the email's body.\r\n" +
                "        </div> -->\r\n" +
                "        <div style=\"display: none; font-size: 1px; line-height: 1px; max-height: 0px; max-width: 0px; opacity: 0; overflow: hidden; mso-hide: all; font-family: sans-serif;\">\r\n" +
                "            Notifications de la solution de traitement automatique des fichiers SFP.\r\n" +
                "        </div>\r\n" +
                "        <!-- Visually Hidden Preheader Text : END -->\r\n" +
                "\r\n" +
                "        <!-- Create white space after the desired preview text so email clients don’t pull other distracting text into the inbox preview. Extend as necessary. -->\r\n" +
                "        <!-- Preview Text Spacing Hack : BEGIN -->\r\n" +
                "        <div style=\"display: none; font-size: 1px; line-height: 1px; max-height: 0px; max-width: 0px; opacity: 0; overflow: hidden; mso-hide: all; font-family: sans-serif;\">\r\n" +
                "	        &zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;\r\n" +
                "        </div>\r\n" +
                "        <!-- Preview Text Spacing Hack : END -->\r\n" +
                "\r\n" +
                "        <!-- Email Body : BEGIN -->\r\n" +
                "        <table align=\"center\" role=\"presentation\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"600\" style=\"margin: auto;\" class=\"email-container\">\r\n" +
                "	        <!-- Email Header : BEGIN -->\r\n" +
                "            <tr>\r\n" +
                "                <td style=\"padding: 20px 0; text-align: center\">\r\n" +
                "                    <!--<img src=\"https://via.placeholder.com/200x50\" width=\"200\" height=\"50\" alt=\"alt_text\" border=\"0\" style=\"height: auto; background: #dddddd; font-family: sans-serif; font-size: 15px; line-height: 15px; color: #555555;\"> -->\r\n" +
                "                </td>\r\n" +
                "            </tr>\r\n" +
                "	        <!-- Email Header : END -->\r\n" +
                "\r\n" +
                "            <!-- Hero Image, Flush : BEGIN -->\r\n" +
                "            <tr>\r\n" +
                "                <td style=\"background-color: #ffffff;\">\r\n" +
                "                   <!--<img src=\"https://via.placeholder.com/1200x600\" width=\"600\" height=\"\" alt=\"alt_text\" border=\"0\" style=\"width: 100%; max-width: 600px; height: auto; background: #dddddd; font-family: sans-serif; font-size: 15px; line-height: 15px; color: #555555; margin: auto; display: block;\" class=\"g-img\">-->\r\n" +
                "                </td>\r\n" +
                "            </tr>\r\n" +
                "            <!-- Hero Image, Flush : END -->\r\n" +
                "\r\n" +
                "            <!-- 1 Column Text + Button : BEGIN -->\r\n" +
                "            <tr>\r\n" +
                "                <td style=\"background-color: #ffffff;\">\r\n" +
                "                    <table role=\"presentation\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"100%\">\r\n" +
                "                       <tr>\r\n" +
                "                            <td style=\"padding: 20px; font-family: sans-serif; font-size: 15px; line-height: 20px; color: #555555;\">\r\n" +
                "                                <p style=\"margin: 0 0 10px;\">"+body+" &nbsp;.</p>\r\n" +
                "                            </td>\r\n" +
                "                        </tr>\r\n" +
                "                        <tr>\r\n" +
                "                            <td style=\"padding: 0 20px 20px;\">\r\n" +
                "                                <!-- Button : BEGIN -->\r\n" +
                "                                <table align=\"center\" role=\"presentation\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\" style=\"margin: auto;\">\r\n" +
                "                                    <tr>\r\n" +
                "                                        <td class=\"button-td button-td-primary\" style=\"border-radius: 4px; background: #cf000c;\">\r\n" +
                "										</td>\r\n" +
                "                                    </tr>\r\n" +
                "                                </table>\r\n" +
                "                                <!-- Button : END -->\r\n" +
                "                            </td>\r\n" +
                "                        </tr>\r\n" +
                "\r\n" +
                "                    </table>\r\n" +
                "                </td>\r\n" +
                "            </tr>\r\n" +
                "            <!-- 1 Column Text + Button : END -->\r\n" +
                "\r\n" +
                "	 \r\n" +
                "	        \r\n" +
                "\r\n" +
                "	        <!-- Clear Spacer : BEGIN -->\r\n" +
                "	        <tr>\r\n" +
                "	            <td aria-hidden=\"true\" height=\"40\" style=\"font-size: 0px; line-height: 0px;\">\r\n" +
                "	                &nbsp;\r\n" +
                "	            </td>\r\n" +
                "	        </tr>\r\n" +
                "	        <!-- Clear Spacer : END -->\r\n" +
                "\r\n" +
                "	        \r\n" +
                "\r\n" +
                "	    </table>\r\n" +
                "	    <!-- Email Body : END -->\r\n" +
                "\r\n" +
                "	    <!-- Email Footer : BEGIN -->\r\n" +
                "        <table align=\"center\" role=\"presentation\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"600\" style=\"margin: auto;\" class=\"email-container\">\r\n" +
                "	        <tr>\r\n" +
                "	            <td style=\"padding: 20px; font-family: sans-serif; font-size: 12px; line-height: 15px; text-align: center; color: #888888;\">\r\n" +
                "	                <!--<webversion style=\"color: #cccccc; text-decoration: underline; font-weight: bold;\">View as a Web Page</webversion> -->\r\n" +
                "	               \r\n" +
                "	               <!-- <unsubscribe style=\"color: #888888; text-decoration: underline;\">unsubscribe</unsubscribe> -->\r\n" +
                "	            </td>\r\n" +
                "	        </tr>\r\n" +
                "	    </table>\r\n" +
                "	    <!-- Email Footer : END -->\r\n" +
                "\r\n" +
                "	    <!-- Full Bleed Background Section : BEGIN -->\r\n" +
                "	    <!--<table role=\"presentation\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"100%\" style=\"background-color: #709f2b;\">-->\r\n" +
                "		<table role=\"presentation\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"100%\" style=\"background-color: #cf000c;\">\r\n" +
                "	        <tr>\r\n" +
                "	            <td>\r\n" +
                "	                <div align=\"center\" style=\"max-width: 600px; margin: auto;\" class=\"email-container\">\r\n" +
                "	                    <!--[if mso]>\r\n" +
                "	                    <table role=\"presentation\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"600\" align=\"center\">\r\n" +
                "	                    <tr>\r\n" +
                "	                    <td>\r\n" +
                "	                    <![endif]-->\r\n" +
                "	                    <table role=\"presentation\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\" width=\"100%\">\r\n" +
                "	                        <tr>\r\n" +
                "	                            <td style=\"padding: 20px; text-align: left; font-family: sans-serif; font-size: 15px; line-height: 20px; color: #ffffff;\">\r\n" +
                "	                                <p style=\"margin: 0;\">Copyright © 2020 UBA. All rights reserved. &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  Version 1.0.1</p>\r\n" +
                "	                            </td>\r\n" +
                "	                        </tr>\r\n" +
                "	                    </table>\r\n" +
                "	                    <!--[if mso]>\r\n" +
                "	                    </td>\r\n" +
                "	                    </tr>\r\n" +
                "	                    </table>\r\n" +
                "	                    <![endif]-->\r\n" +
                "	                </div>\r\n" +
                "	            </td>\r\n" +
                "	        </tr>\r\n" +
                "	    </table>\r\n" +
                "	    <!-- Full Bleed Background Section : END -->\r\n" +
                "\r\n" +
                "    <!--[if mso | IE]>\r\n" +
                "    </td>\r\n" +
                "    </tr>\r\n" +
                "    </table>\r\n" +
                "    <![endif]-->\r\n" +
                "    </center>\r\n" +
                "</body>\r\n" +
                "</html>";

        return html;
    }
}
