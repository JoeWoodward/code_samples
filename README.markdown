# Code Examples #

## Authorised Notices ##

This demonstrates a method of creating notices (A post with a title,
body, image, email, and phone number) that need administrator approval
before they become visable on the site.

In this example the end user creates a notice, the notice has an attribute
called 'activated' which is set to false. When the notice is created an
notification email is sent to the administrator in charge of authorising
notices. The admin can then follow a link from the email to an
administrators panel allowing him/her to accept or delete the notice.

If the end user updates the notice the notice will need to be activated
again by the administrator.

Ideally in the situation that the administrator didn't approve the
comment, the admin would be able to give a reason which would be emailed
to the end user

## Payment Processor ##

I have included a payment processor that I wrote for a client to process
payments through chargify.com

This demonstrates how to get the URL for a hosted pament page for new
users and also an update billing infomation page. Both of these pages
are hosted by chargify and have unique URLs for each user.

The Payment Processor class handles retrieving these URLs using keys
provided by chargify.

Chargify provides webhooks to keep the app in sync with chargify, I have
provided a hooks controller which recieves an encrypted payload which is
verified and then converted and processed. This handles actions like
'Payment Successful' and then sets the user.active attribute to
'active'
