---
layout: contact
title: Contact
---

<link href="/assets/css/contact.css" rel="stylesheet"/>

<!--contactme form-->
<div id="contactme-section">
<h1 id="contact">Contact</h1>
<form action="https://formspree.io/kevy.vinu@gmail.com" method="POST" class="form" id="contact-form">
  <p>You can also send me a quick message using the form below:</p>
  <div class="row">
    <div class="col-xs-6">
      <input type="email" name="_replyto" class="form-control input-lg" placeholder="Your Email" title="Email">
    </div>
    <div class="col-xs-6">
      <input type="text" name="name" class="form-control input-lg" placeholder="Your Name" title="Name">
    </div>
  </div>
  <input type="hidden" name="_subject" value="New submission from linuxmate.ml">
  <textarea type="text" name="content" class="form-control input-lg" placeholder="Message" title="Message" required="required" rows="3"></textarea>
  <input type="text" name="_gotcha" style="display:none">
  <input type="hidden" name="_next" value="./aboutme?message=Your message was sent successfully, thanks!" />
<br>
  <button type="submit" class="btn btn-lg btn-primary">Submit</button>
</form>

<br>
<form method="get" action="https://goo.gl/5w8ccu" id="contact-form">
<p>If security is your primary concern, download my P/GPG key from here</p>
<button type="submit" class="btn btn-lg btn-primary">14D8 B939 7A8F 10DA 44B0  0FE3 B5CC F2B7 D917 627C</button>
</form>
