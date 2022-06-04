const express = require('express');
const bodyParser = require('body-parser');
const port = 3000;
const app = express();

app.use(bodyParser.json());

const { Gateway, Wallets } = require('fabric-network');
const fs = require('fs');
const path = require('path');

// 初始化帳本
app.post('/api/InitialLedger', async function (req, res) {
    try {
        // load the network configuration
        const ccpPath = path.resolve(__dirname, '..', 'bidding-network', 'organizations', 'peerOrganizations', 'tn.edu.tw', 'connection-tn.json');
        let ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);

        // Check to see if we've already enrolled the user.
        const identity = await wallet.get('appUser');
        if (!identity) {
            console.log('An identity for the user "appUser" does not exist in the wallet');
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, { wallet, identity: 'appUser', discovery: { enabled: true, asLocalhost: true } });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork('bidding-channel');

        // Get the contract from the network.
        const contract = network.getContract('bidding');

        // Submit the specified transaction.
        await contract.submitTransaction('initLedger');

        res.send({ 
            "Status": 0, 
            "Message": "帳本初始化成功"
        });

        // Disconnect from the gateway.
        await gateway.disconnect();

    } catch (error) {
        res.send({
            "Status": 1,
            "Message": `Failed to submit transaction: ${error}`
        });
    }
})

// 招標單上鏈
app.post('/api/tn/SubmitBiddingInfo', async function (req, res) {
    try {
        // load the network configuration
        const ccpPath = path.resolve(__dirname, '..', 'bidding-network', 'organizations', 'peerOrganizations', 'tn.edu.tw', 'connection-tn.json');
        let ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);

        // Check to see if we've already enrolled the user.
        const identity = await wallet.get('appUser');
        if (!identity) {
            console.log('An identity for the user "appUser" does not exist in the wallet');
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, { wallet, identity: 'appUser', discovery: { enabled: true, asLocalhost: true } });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork('bidding-channel');

        // Get the contract from the network.
        const contract = network.getContract('bidding');

        // 判斷招標單是否存在
        const result = await contract.evaluateTransaction('query_bidding');
        let bidding_result = JSON.parse(result.toString());
        let bidding_exist = false;
        for (let item of bidding_result['record']) {
            if (item['biddingId'] === req.body.biddingId) {
                bidding_exist = true;
                break;
            }
        }
        if (bidding_exist) {
            res.send({
                "Status": 1,
                "Message": "此招標單已存在，招標單上鏈失敗"
            });
        } else {
            // Submit the specified transaction.
            await contract.submitTransaction('submit_bidding', JSON.stringify(req.body));
            res.send({ 
                "Status": 0,
                "Message": "招標單上鏈成功"
            });
        }

        // Disconnect from the gateway.
        await gateway.disconnect();

    } catch (error) {
        res.send({ 
            "Status": 1,
            "Message": `Failed to submit transaction: ${error}`
        });
    }
})

// 取得上鏈的招標單資料
app.get('/api/tn/GetBiddingInfo', async function (req, res) {
    try {
        // load the network configuration
        const ccpPath = path.resolve(__dirname, '..', 'bidding-network', 'organizations', 'peerOrganizations', 'tn.edu.tw', 'connection-tn.json');
        const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);

        // Check to see if we've already enrolled the user.
        const identity = await wallet.get('appUser');
        if (!identity) {
            console.log('An identity for the user "appUser" does not exist in the wallet');
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, { wallet, identity: 'appUser', discovery: { enabled: true, asLocalhost: true } });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork('bidding-channel');

        // Get the contract from the network.
        const contract = network.getContract('bidding');

        // Evaluate the specified transaction.
        const result = await contract.evaluateTransaction('query_bidding');

        let bidding_result = JSON.parse(result.toString());

        // 判斷招標單編號是否輸入、招標單是否存在
        if (req.query.BiddingId) {
            let bidding_exist = false;
            for (let item of bidding_result['record']) {
                if (item['biddingId'] === req.query.BiddingId) {
                    bidding_exist = true;
                    res.send({
                        "Status": 0,
                        "Message": "招標單查詢成功",
                        "BiddingInfo": item['data']
                    });
                    break;
                }
            }
            if (! bidding_exist) {
                res.send({
                    "Status": 1,
                    "Message": "此招標單不存在，招標單查詢失敗"
                });
            }
        } else {
            res.send({
                "Status": 1,
                "Message": "請輸入招標單編號，招標單查詢失敗"
            });
        }

        // Disconnect from the gateway.
        await gateway.disconnect();
      
    } catch (error) {
        res.send({
            "Status": 1,
            "Message": `Failed to evaluate transaction: ${error}`
        });
    }
})

// 決標單上鏈
app.post('/api/tn/SubmitAwardInfo', async function (req, res) {
    try {
        // load the network configuration
        const ccpPath = path.resolve(__dirname, '..', 'bidding-network', 'organizations', 'peerOrganizations', 'tn.edu.tw', 'connection-tn.json');
        let ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);

        // Check to see if we've already enrolled the user.
        const identity = await wallet.get('appUser');
        if (!identity) {
            console.log('An identity for the user "appUser" does not exist in the wallet');
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, { wallet, identity: 'appUser', discovery: { enabled: true, asLocalhost: true } });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork('bidding-channel');

        // Get the contract from the network.
        const contract = network.getContract('bidding');

        // 判斷決標單是否存在
        const result = await contract.evaluateTransaction('query_award');
        let award_result = JSON.parse(result.toString());
        let award_exist = false;
        for (let item of award_result['record']) {
            if (item['awardId'] === req.body.awardId) {
                award_exist = true;
                break;
            }
        }
        if (award_exist) {
            res.send({
                "Status": 1,
                "Message": "此決標單已存在，決標單上鏈失敗"
            });
        } else {
            // Submit the specified transaction.
            await contract.submitTransaction('submit_award', JSON.stringify(req.body));
            res.send({ 
                "Status": 0,
                "Message": "決標單上鏈成功"
            });
        }

        // Disconnect from the gateway.
        await gateway.disconnect();

    } catch (error) {
        res.send({ 
            "Status": 1,
            "Message": `Failed to submit transaction: ${error}`
        });
    }
})

// 取得上鏈的決標單資料
app.get('/api/tn/GetAwardInfo', async function (req, res) {
    try {
        // load the network configuration
        const ccpPath = path.resolve(__dirname, '..', 'bidding-network', 'organizations', 'peerOrganizations', 'tn.edu.tw', 'connection-tn.json');
        const ccp = JSON.parse(fs.readFileSync(ccpPath, 'utf8'));

        // Create a new file system based wallet for managing identities.
        const walletPath = path.join(process.cwd(), 'wallet');
        const wallet = await Wallets.newFileSystemWallet(walletPath);

        // Check to see if we've already enrolled the user.
        const identity = await wallet.get('appUser');
        if (!identity) {
            console.log('An identity for the user "appUser" does not exist in the wallet');
            console.log('Run the registerUser.js application before retrying');
            return;
        }

        // Create a new gateway for connecting to our peer node.
        const gateway = new Gateway();
        await gateway.connect(ccp, { wallet, identity: 'appUser', discovery: { enabled: true, asLocalhost: true } });

        // Get the network (channel) our contract is deployed to.
        const network = await gateway.getNetwork('bidding-channel');

        // Get the contract from the network.
        const contract = network.getContract('bidding');

        // Evaluate the specified transaction.
        const result = await contract.evaluateTransaction('query_award');

        let award_result = JSON.parse(result.toString());

        // 判斷決標單編號是否輸入、決標單是否存在
        if (req.query.AwardId) {
            let award_exist = false;
            for (let item of award_result['record']) {
                if (item['awardId'] === req.query.AwardId) {
                    award_exist = true;
                    res.send({
                        "Status": 0,
                        "Message": "決標單查詢成功",
                        "AwardInfo": item['data']
                    });
                    break;
                }
            }
            if (! award_exist) {
                res.send({
                    "Status": 1,
                    "Message": "此決標單不存在，決標單查詢失敗"
                });
            }
        } else {
            res.send({
                "Status": 1,
                "Message": "請輸入決標單編號，決標單查詢失敗"
            });
        }

        // Disconnect from the gateway.
        await gateway.disconnect();
      
    } catch (error) {
        res.send({
            "Status": 1,
            "Message": `Failed to evaluate transaction: ${error}`
        });
    }
})

app.listen(port, () => {
    console.log(`API listening on port ${port}`)
})