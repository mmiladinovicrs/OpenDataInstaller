﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ODI.Service;

namespace ODI.Controllers
{
    public class AzureController : Controller
    {

        public ActionResult GenCert(string key)
        {
            var ret = CertificateBuilder.MakeCertificate(key);
            return File(ret, "application/","certificate.cer");
        }

    }
}
