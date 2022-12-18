# On-Demand Wireguard VPN Server
This repository allows you to create a VPN server on demand (powered by Wireguard) on any AWS account and destroy it on demand by a simple click (or a few clicks, maybe even a few keyboard buttons for copy / paste, you get it.)

## Motivation
*First:* It is fun, if you don't think so, you are not a developer :)

*Second:* Everyone needs a VPN connection these days, whether, for blocked VoIP calls, untrusted websites, blocked websites in your country, you name it.

However, if you like me, you don't like the commitment of monthly payments to a commercial VPN that claims they never sell your data (or at least they try to), sharing the same network with others, or at best won't use for more than few hours a month, then this is for you.

## Work in Progress
While it is functional, I'm still trying to make this a non-technical user-friendly, but for now, you still need some basic knowledge.

### Key features::
- **Powered by Wireguard**: You can check the official [website](https://www.wireguard.com/) for all the great features such as cryptography that doesn't rely on username/passwords for connection, speed, and so on.
- **Pay as you go**: You only pay for the time the infrastructure is up. Once you destroy the infrastructure, you won't pay anything.
- **Completely dedicated to you**: The server is built solely for you, you are sharing neither the network nor the computing power with anyone.

### Requirements
- AWS Account with a credit card for payments
- Wireguard client

## Cost
I haven't been able to estimate the actual cost of running this but here are some of the resources costs from an actual bill:

- $0.0132 per On Demand Linux t3.micro Instance Hour
- $0.12 per GB-month of General Purpose SSD (gp2) provisioned storage - Asia Pacific (Singapore)

Notice that some of the services are considered in the free-tier like data transfer and emails (200 a day) and so on. 
If you already consumed your free tier you might be charged differently.

## Usage
You need to add 4 secrets to the GitHub Actions:
- AWS_ACCESS_KEY
- AWS_SECRET_KEY
The first two are straightforward, these are the credentials that will be used to create the resources.  
This is the part where you need some technical knowledge, I will try to simplify this in the future, but for now, google is your friend.  
The credentials should have a policy attached to them (find policy.json file), I made it as small as possible to have the only needed permissions to create the needed resources.

- EMAIL_ADDRESS:
 is used to send the credentials generated by the scripts, it will first send you an email to allow AWS to send emails, look for it when you run the `Create AWS` job. Otherwise, it will fail to send you the credentials.
- AWS_REGION:   
the AWS region you want the server to be hosted in, currently  Singapore `ap-southeast-1` is supported by the script, so you don't have to put it unless you want to update the scripts manually to consider it.

You need to fork this repo under your GitHub Account, put the above secrets in the GitHub Actions secrets, and you will be ready to go.

![image](https://user-images.githubusercontent.com/1418564/208293160-08d3638a-85b1-439b-aed5-34fd4676bc68.png)

## Creating the server

Go to the Actions tab, find the `Create Wireguard Platform on AWS` workflow, and click Run workflow. It might require approval by clicking `Approve & deploy` by the owner of the GitHub repo (you in this case).

![chrome_QWR5MU15yb](https://user-images.githubusercontent.com/1418564/208294458-559f1770-5b36-4488-bd86-0673bf424958.gif)

You can check the output of the workflow and look for 
`You should have received an email from AWS asking you to verify your email address so we can send you an email with the keys ...` 
message, this means you have to check your inbox to find the AWS subscription approval.

### Screenshots
<img src="https://user-images.githubusercontent.com/1418564/208296368-14675690-91ac-4ec5-9e6c-5246cae5eff9.png" width="900">

<img src="https://user-images.githubusercontent.com/1418564/208296464-47ddbfcb-2a1f-4152-93c0-c05a5743564a.png" width="600">

<img src="https://user-images.githubusercontent.com/1418564/208296379-5c25f5cd-0f25-477a-b969-73855a36c9f1.png" width="600">


Once the workflow finishes, you will receive an email with the client configuration that can be used to connect to the server.

<img src="https://user-images.githubusercontent.com/1418564/208296792-390a062d-f4c4-4c85-b8b2-68b602b6a5a6.png" width="600">

Open the Wireguard client (installation instructions [here](https://www.wireguard.com/install/), click Add Tunnel -> Add Empty Tunnel, copy the configuration from the email and paste it in the text box, click Save and you are done.

<img src="https://user-images.githubusercontent.com/1418564/208296879-c801298e-d70e-4fbb-a300-f5d0fcef6871.png" width="600">

To activate the connection, just click Activate. Enjoy.

## Destroying the resources
To destroy the resources, go to the Actions tab, find the Destroy job, and run it.
That's it. You are done.

## Known issues
- If you fail to approve the email subscription on time, the workflow will end without sending the Wireguard client credentials and you have to destroy the resources and start over.
- You shouldn't run the `Destroy` job while the `Create AWS` job is running, the results are unexpected and could result in billable astray resources.
- Cancelling the workflow while it is building up the resources or destroying it could also have an unexpcted results, please wait till the workflow finishes before running another.

## Things to be done
- I'm looking for a better way to share Wireguard credentials rather than sending them by email.
- The Wireguard configuration client (credentials) need to be sent as an attachment rather than plain text.
- Adding an automated way to download the client and set up the connection without user intervention.
- The server runs in Singapore region which might not be suitable for everyone. Adding a way to specify the region would be great.

## Disclaimer
This is a personal project that is not meant to be used professionally. It comes without any support, use it on your own.
If you don't know how AWS billing work, be careful not to accure unintended charges.

## Credits
This repo is a fork of  [sosedoff/wireguard-aws-gateway](https://github.com/sosedoff/wireguard-aws-gateway) repository but the original one requires you to run the commands locally on your machine one by one.

This one, however, is already prepared to use GitHub Actions to build the infrastructure with a click of a button and destroy it with another.


