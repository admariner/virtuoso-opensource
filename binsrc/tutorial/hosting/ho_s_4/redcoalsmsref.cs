//  
//  This file is part of the OpenLink Software Virtuoso Open-Source (VOS)
//  project.
//  
//  Copyright (C) 1998-2025 OpenLink Software
//  
//  This project is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the
//  Free Software Foundation; only version 2 of the License, dated June 1991.
//  
//  This program is distributed in the hope that it will be useful, but
//  WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//  General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
//  
//  
﻿//------------------------------------------------------------------------------
// <autogenerated>
//     This code was generated by a tool.
//     Runtime Version: 1.0.3705.288
//
//     Changes to this file may cause incorrect behavior and will be lost if 
//     the code is regenerated.
// </autogenerated>
//------------------------------------------------------------------------------

// 
// This source code was auto-generated by Microsoft.VSDesigner, Version 1.0.3705.288.
// 
namespace redcoalsms.net.redcoal.xml {
    using System.Diagnostics;
    using System.Xml.Serialization;
    using System;
    using System.Web.Services.Protocols;
    using System.ComponentModel;
    using System.Web.Services;
    
    
    /// <remarks/>
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Web.Services.WebServiceBindingAttribute(Name="ISOAPServerbinding", Namespace="http://tempuri.org/")]
    public class ISOAPServerservice : System.Web.Services.Protocols.SoapHttpClientProtocol {
        
        /// <remarks/>
        public ISOAPServerservice() {
            this.Url = "http://xml.redcoal.com/soapserver.dll/soap/ISoapServer";
        }
        
        /// <remarks/>
        [System.Web.Services.Protocols.SoapRpcMethodAttribute("urn:SOAPServerImpl-ISOAPServer#SendTextSMS", RequestNamespace="urn:SOAPServerImpl-ISOAPServer", ResponseNamespace="urn:SOAPServerImpl-ISOAPServer")]
        [return: System.Xml.Serialization.SoapElementAttribute("return")]
        public int SendTextSMS(string strInSerialNo, string strInSMSKey, string strInRecipients, string strInMessageText, string strInReplyEmail, string strInOriginator, int iInType, ref string strOutMessageIDs) {
            object[] results = this.Invoke("SendTextSMS", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        strInRecipients,
                        strInMessageText,
                        strInReplyEmail,
                        strInOriginator,
                        iInType,
                        strOutMessageIDs});
            strOutMessageIDs = ((string)(results[1]));
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        public System.IAsyncResult BeginSendTextSMS(string strInSerialNo, string strInSMSKey, string strInRecipients, string strInMessageText, string strInReplyEmail, string strInOriginator, int iInType, string strOutMessageIDs, System.AsyncCallback callback, object asyncState) {
            return this.BeginInvoke("SendTextSMS", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        strInRecipients,
                        strInMessageText,
                        strInReplyEmail,
                        strInOriginator,
                        iInType,
                        strOutMessageIDs}, callback, asyncState);
        }
        
        /// <remarks/>
        public int EndSendTextSMS(System.IAsyncResult asyncResult, out string strOutMessageIDs) {
            object[] results = this.EndInvoke(asyncResult);
            strOutMessageIDs = ((string)(results[1]));
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        [System.Web.Services.Protocols.SoapRpcMethodAttribute("urn:SOAPServerImpl-ISOAPServer#SendBinarySMS", RequestNamespace="urn:SOAPServerImpl-ISOAPServer", ResponseNamespace="urn:SOAPServerImpl-ISOAPServer")]
        [return: System.Xml.Serialization.SoapElementAttribute("return")]
        public int SendBinarySMS(string strInSerialNo, string strInSMSKey, string strInRecipients, [System.Xml.Serialization.SoapElementAttribute(DataType="base64Binary")] System.Byte[] strInBinaryContent, string strInExtraParam, string strInReplyEmail, int iInType, ref string strOutMessageIDs) {
            object[] results = this.Invoke("SendBinarySMS", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        strInRecipients,
                        strInBinaryContent,
                        strInExtraParam,
                        strInReplyEmail,
                        iInType,
                        strOutMessageIDs});
            strOutMessageIDs = ((string)(results[1]));
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        public System.IAsyncResult BeginSendBinarySMS(string strInSerialNo, string strInSMSKey, string strInRecipients, System.Byte[] strInBinaryContent, string strInExtraParam, string strInReplyEmail, int iInType, string strOutMessageIDs, System.AsyncCallback callback, object asyncState) {
            return this.BeginInvoke("SendBinarySMS", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        strInRecipients,
                        strInBinaryContent,
                        strInExtraParam,
                        strInReplyEmail,
                        iInType,
                        strOutMessageIDs}, callback, asyncState);
        }
        
        /// <remarks/>
        public int EndSendBinarySMS(System.IAsyncResult asyncResult, out string strOutMessageIDs) {
            object[] results = this.EndInvoke(asyncResult);
            strOutMessageIDs = ((string)(results[1]));
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        [System.Web.Services.Protocols.SoapRpcMethodAttribute("urn:SOAPServerImpl-ISOAPServer#CheckMessageStatus", RequestNamespace="urn:SOAPServerImpl-ISOAPServer", ResponseNamespace="urn:SOAPServerImpl-ISOAPServer")]
        [return: System.Xml.Serialization.SoapElementAttribute("return")]
        public int CheckMessageStatus(string strInSerialNo, string strInSMSKey, string strInMessageIDs, ref string strOutMessageStatus) {
            object[] results = this.Invoke("CheckMessageStatus", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        strInMessageIDs,
                        strOutMessageStatus});
            strOutMessageStatus = ((string)(results[1]));
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        public System.IAsyncResult BeginCheckMessageStatus(string strInSerialNo, string strInSMSKey, string strInMessageIDs, string strOutMessageStatus, System.AsyncCallback callback, object asyncState) {
            return this.BeginInvoke("CheckMessageStatus", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        strInMessageIDs,
                        strOutMessageStatus}, callback, asyncState);
        }
        
        /// <remarks/>
        public int EndCheckMessageStatus(System.IAsyncResult asyncResult, out string strOutMessageStatus) {
            object[] results = this.EndInvoke(asyncResult);
            strOutMessageStatus = ((string)(results[1]));
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        [System.Web.Services.Protocols.SoapRpcMethodAttribute("urn:SOAPServerImpl-ISOAPServer#GetPropertyPage", RequestNamespace="urn:SOAPServerImpl-ISOAPServer", ResponseNamespace="urn:SOAPServerImpl-ISOAPServer")]
        [return: System.Xml.Serialization.SoapElementAttribute("return")]
        public int GetPropertyPage(string strInSerialNo, string strInSMSKey, ref string strOutContent, bool bFirstUse) {
            object[] results = this.Invoke("GetPropertyPage", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        strOutContent,
                        bFirstUse});
            strOutContent = ((string)(results[1]));
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        public System.IAsyncResult BeginGetPropertyPage(string strInSerialNo, string strInSMSKey, string strOutContent, bool bFirstUse, System.AsyncCallback callback, object asyncState) {
            return this.BeginInvoke("GetPropertyPage", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        strOutContent,
                        bFirstUse}, callback, asyncState);
        }
        
        /// <remarks/>
        public int EndGetPropertyPage(System.IAsyncResult asyncResult, out string strOutContent) {
            object[] results = this.EndInvoke(asyncResult);
            strOutContent = ((string)(results[1]));
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        [System.Web.Services.Protocols.SoapRpcMethodAttribute("urn:SOAPServerImpl-ISOAPServer#GetCreditsLeft", RequestNamespace="urn:SOAPServerImpl-ISOAPServer", ResponseNamespace="urn:SOAPServerImpl-ISOAPServer")]
        [return: System.Xml.Serialization.SoapElementAttribute("return")]
        public int GetCreditsLeft(string strInSerialNo, string strInSMSKey, ref System.Double dOutCreditsLeft) {
            object[] results = this.Invoke("GetCreditsLeft", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        dOutCreditsLeft});
            dOutCreditsLeft = ((System.Double)(results[1]));
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        public System.IAsyncResult BeginGetCreditsLeft(string strInSerialNo, string strInSMSKey, System.Double dOutCreditsLeft, System.AsyncCallback callback, object asyncState) {
            return this.BeginInvoke("GetCreditsLeft", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        dOutCreditsLeft}, callback, asyncState);
        }
        
        /// <remarks/>
        public int EndGetCreditsLeft(System.IAsyncResult asyncResult, out System.Double dOutCreditsLeft) {
            object[] results = this.EndInvoke(asyncResult);
            dOutCreditsLeft = ((System.Double)(results[1]));
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        [System.Web.Services.Protocols.SoapRpcMethodAttribute("urn:SOAPServerImpl-ISOAPServer#GetLicenseInformation", RequestNamespace="urn:SOAPServerImpl-ISOAPServer", ResponseNamespace="urn:SOAPServerImpl-ISOAPServer")]
        [return: System.Xml.Serialization.SoapElementAttribute("return")]
        public int GetLicenseInformation(string strInSerialNo, string strInSMSKey, ref string strOutLicenseInfo) {
            object[] results = this.Invoke("GetLicenseInformation", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        strOutLicenseInfo});
            strOutLicenseInfo = ((string)(results[1]));
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        public System.IAsyncResult BeginGetLicenseInformation(string strInSerialNo, string strInSMSKey, string strOutLicenseInfo, System.AsyncCallback callback, object asyncState) {
            return this.BeginInvoke("GetLicenseInformation", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        strOutLicenseInfo}, callback, asyncState);
        }
        
        /// <remarks/>
        public int EndGetLicenseInformation(System.IAsyncResult asyncResult, out string strOutLicenseInfo) {
            object[] results = this.EndInvoke(asyncResult);
            strOutLicenseInfo = ((string)(results[1]));
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        [System.Web.Services.Protocols.SoapRpcMethodAttribute("urn:SOAPServerImpl-ISOAPServer#GetIncomingMessage", RequestNamespace="urn:SOAPServerImpl-ISOAPServer", ResponseNamespace="urn:SOAPServerImpl-ISOAPServer")]
        [return: System.Xml.Serialization.SoapElementAttribute("return")]
        public int GetIncomingMessage(string strInSerialNo, string strInSMSKey, string strInReplyEmail, ref string strOutSender, ref string strOutMessageContent, ref string strOutTimeStamp, ref int iOutMessagesLeft) {
            object[] results = this.Invoke("GetIncomingMessage", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        strInReplyEmail,
                        strOutSender,
                        strOutMessageContent,
                        strOutTimeStamp,
                        iOutMessagesLeft});
            strOutSender = ((string)(results[1]));
            strOutMessageContent = ((string)(results[2]));
            strOutTimeStamp = ((string)(results[3]));
            iOutMessagesLeft = ((int)(results[4]));
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        public System.IAsyncResult BeginGetIncomingMessage(string strInSerialNo, string strInSMSKey, string strInReplyEmail, string strOutSender, string strOutMessageContent, string strOutTimeStamp, int iOutMessagesLeft, System.AsyncCallback callback, object asyncState) {
            return this.BeginInvoke("GetIncomingMessage", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        strInReplyEmail,
                        strOutSender,
                        strOutMessageContent,
                        strOutTimeStamp,
                        iOutMessagesLeft}, callback, asyncState);
        }
        
        /// <remarks/>
        public int EndGetIncomingMessage(System.IAsyncResult asyncResult, out string strOutSender, out string strOutMessageContent, out string strOutTimeStamp, out int iOutMessagesLeft) {
            object[] results = this.EndInvoke(asyncResult);
            strOutSender = ((string)(results[1]));
            strOutMessageContent = ((string)(results[2]));
            strOutTimeStamp = ((string)(results[3]));
            iOutMessagesLeft = ((int)(results[4]));
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        [System.Web.Services.Protocols.SoapRpcMethodAttribute("urn:SOAPServerImpl-ISOAPServer#EnterSchedule", RequestNamespace="urn:SOAPServerImpl-ISOAPServer", ResponseNamespace="urn:SOAPServerImpl-ISOAPServer")]
        [return: System.Xml.Serialization.SoapElementAttribute("return")]
        public int EnterSchedule(string strInSerialNo, string strInSMSKey, string strInRecipients, string strInMessageText, string strInReplyEmail, string strInOriginator, System.Double dInDateTime, System.Double dInRefTime, int iInType) {
            object[] results = this.Invoke("EnterSchedule", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        strInRecipients,
                        strInMessageText,
                        strInReplyEmail,
                        strInOriginator,
                        dInDateTime,
                        dInRefTime,
                        iInType});
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        public System.IAsyncResult BeginEnterSchedule(string strInSerialNo, string strInSMSKey, string strInRecipients, string strInMessageText, string strInReplyEmail, string strInOriginator, System.Double dInDateTime, System.Double dInRefTime, int iInType, System.AsyncCallback callback, object asyncState) {
            return this.BeginInvoke("EnterSchedule", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        strInRecipients,
                        strInMessageText,
                        strInReplyEmail,
                        strInOriginator,
                        dInDateTime,
                        dInRefTime,
                        iInType}, callback, asyncState);
        }
        
        /// <remarks/>
        public int EndEnterSchedule(System.IAsyncResult asyncResult) {
            object[] results = this.EndInvoke(asyncResult);
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        [System.Web.Services.Protocols.SoapRpcMethodAttribute("urn:SOAPServerImpl-ISOAPServer#EnterScheduleExt", RequestNamespace="urn:SOAPServerImpl-ISOAPServer", ResponseNamespace="urn:SOAPServerImpl-ISOAPServer")]
        [return: System.Xml.Serialization.SoapElementAttribute("return")]
        public int EnterScheduleExt(string strInSerialNo, string strInSMSKey, string strInRecipients, string strInMessageText, string strInReplyEmail, string strInOriginator, System.Double dInDateTime, System.Double dInRefTime, int iInType, ref string strOutMessageIDs) {
            object[] results = this.Invoke("EnterScheduleExt", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        strInRecipients,
                        strInMessageText,
                        strInReplyEmail,
                        strInOriginator,
                        dInDateTime,
                        dInRefTime,
                        iInType,
                        strOutMessageIDs});
            strOutMessageIDs = ((string)(results[1]));
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        public System.IAsyncResult BeginEnterScheduleExt(string strInSerialNo, string strInSMSKey, string strInRecipients, string strInMessageText, string strInReplyEmail, string strInOriginator, System.Double dInDateTime, System.Double dInRefTime, int iInType, string strOutMessageIDs, System.AsyncCallback callback, object asyncState) {
            return this.BeginInvoke("EnterScheduleExt", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        strInRecipients,
                        strInMessageText,
                        strInReplyEmail,
                        strInOriginator,
                        dInDateTime,
                        dInRefTime,
                        iInType,
                        strOutMessageIDs}, callback, asyncState);
        }
        
        /// <remarks/>
        public int EndEnterScheduleExt(System.IAsyncResult asyncResult, out string strOutMessageIDs) {
            object[] results = this.EndInvoke(asyncResult);
            strOutMessageIDs = ((string)(results[1]));
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        [System.Web.Services.Protocols.SoapRpcMethodAttribute("urn:SOAPServerImpl-ISOAPServer#DeleteSchedule", RequestNamespace="urn:SOAPServerImpl-ISOAPServer", ResponseNamespace="urn:SOAPServerImpl-ISOAPServer")]
        [return: System.Xml.Serialization.SoapElementAttribute("return")]
        public int DeleteSchedule(string strInSerialNo, string strInSMSKey, string strInMessageIDs) {
            object[] results = this.Invoke("DeleteSchedule", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        strInMessageIDs});
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        public System.IAsyncResult BeginDeleteSchedule(string strInSerialNo, string strInSMSKey, string strInMessageIDs, System.AsyncCallback callback, object asyncState) {
            return this.BeginInvoke("DeleteSchedule", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        strInMessageIDs}, callback, asyncState);
        }
        
        /// <remarks/>
        public int EndDeleteSchedule(System.IAsyncResult asyncResult) {
            object[] results = this.EndInvoke(asyncResult);
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        [System.Web.Services.Protocols.SoapRpcMethodAttribute("urn:SOAPServerImpl-ISOAPServer#GetListNames", RequestNamespace="urn:SOAPServerImpl-ISOAPServer", ResponseNamespace="urn:SOAPServerImpl-ISOAPServer")]
        [return: System.Xml.Serialization.SoapElementAttribute("return")]
        public int GetListNames(string strInSerialNo, string strInSMSKey, ref string strOutListNames) {
            object[] results = this.Invoke("GetListNames", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        strOutListNames});
            strOutListNames = ((string)(results[1]));
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        public System.IAsyncResult BeginGetListNames(string strInSerialNo, string strInSMSKey, string strOutListNames, System.AsyncCallback callback, object asyncState) {
            return this.BeginInvoke("GetListNames", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        strOutListNames}, callback, asyncState);
        }
        
        /// <remarks/>
        public int EndGetListNames(System.IAsyncResult asyncResult, out string strOutListNames) {
            object[] results = this.EndInvoke(asyncResult);
            strOutListNames = ((string)(results[1]));
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        [System.Web.Services.Protocols.SoapRpcMethodAttribute("urn:SOAPServerImpl-ISOAPServer#GetListEntries", RequestNamespace="urn:SOAPServerImpl-ISOAPServer", ResponseNamespace="urn:SOAPServerImpl-ISOAPServer")]
        [return: System.Xml.Serialization.SoapElementAttribute("return")]
        public int GetListEntries(string strInSerialNo, string strInSMSKey, int iInListID, ref string strOutListEntries) {
            object[] results = this.Invoke("GetListEntries", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        iInListID,
                        strOutListEntries});
            strOutListEntries = ((string)(results[1]));
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        public System.IAsyncResult BeginGetListEntries(string strInSerialNo, string strInSMSKey, int iInListID, string strOutListEntries, System.AsyncCallback callback, object asyncState) {
            return this.BeginInvoke("GetListEntries", new object[] {
                        strInSerialNo,
                        strInSMSKey,
                        iInListID,
                        strOutListEntries}, callback, asyncState);
        }
        
        /// <remarks/>
        public int EndGetListEntries(System.IAsyncResult asyncResult, out string strOutListEntries) {
            object[] results = this.EndInvoke(asyncResult);
            strOutListEntries = ((string)(results[1]));
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        [System.Web.Services.Protocols.SoapRpcMethodAttribute("urn:SOAPServerImpl-ISOAPServer#RegisterAccount", RequestNamespace="urn:SOAPServerImpl-ISOAPServer", ResponseNamespace="urn:SOAPServerImpl-ISOAPServer")]
        [return: System.Xml.Serialization.SoapElementAttribute("return")]
        public int RegisterAccount(string strInSerialNo, string strInEmailAddress, string strInName, string strInOrganization, int iInCountryID) {
            object[] results = this.Invoke("RegisterAccount", new object[] {
                        strInSerialNo,
                        strInEmailAddress,
                        strInName,
                        strInOrganization,
                        iInCountryID});
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        public System.IAsyncResult BeginRegisterAccount(string strInSerialNo, string strInEmailAddress, string strInName, string strInOrganization, int iInCountryID, System.AsyncCallback callback, object asyncState) {
            return this.BeginInvoke("RegisterAccount", new object[] {
                        strInSerialNo,
                        strInEmailAddress,
                        strInName,
                        strInOrganization,
                        iInCountryID}, callback, asyncState);
        }
        
        /// <remarks/>
        public int EndRegisterAccount(System.IAsyncResult asyncResult) {
            object[] results = this.EndInvoke(asyncResult);
            return ((int)(results[0]));
        }
        
        /// <remarks/>
        [System.Web.Services.Protocols.SoapRpcMethodAttribute("urn:SOAPServerImpl-ISOAPServer#RedWebServiceVersion", RequestNamespace="urn:SOAPServerImpl-ISOAPServer", ResponseNamespace="urn:SOAPServerImpl-ISOAPServer")]
        [return: System.Xml.Serialization.SoapElementAttribute("return")]
        public string RedWebServiceVersion() {
            object[] results = this.Invoke("RedWebServiceVersion", new object[0]);
            return ((string)(results[0]));
        }
        
        /// <remarks/>
        public System.IAsyncResult BeginRedWebServiceVersion(System.AsyncCallback callback, object asyncState) {
            return this.BeginInvoke("RedWebServiceVersion", new object[0], callback, asyncState);
        }
        
        /// <remarks/>
        public string EndRedWebServiceVersion(System.IAsyncResult asyncResult) {
            object[] results = this.EndInvoke(asyncResult);
            return ((string)(results[0]));
        }
    }
}
