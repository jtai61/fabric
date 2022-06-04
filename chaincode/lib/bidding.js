/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Contract } = require('fabric-contract-api');

class Bidding extends Contract {

    // 初始化帳本
    async initLedger(ctx) {
        console.info('============= START : Initialize Ledger ===========');
        const data = [
            {
                key: 'bidding',
                record: [],
            },
            {
                key: 'award',
                record: [],
            },
        ];

        for (const item of data) {
            await ctx.stub.putState(item.key, Buffer.from(JSON.stringify(item)));
        }
        console.info('============= END : Initialize Ledger ===========');
    }

    // 招標單上鏈
    async submit_bidding(ctx, new_bidding) {
        // 取得目前上鏈的招標單
        const bidding_AsBytes = await ctx.stub.getState('bidding');
        if (!bidding_AsBytes || bidding_AsBytes.length === 0) {
            throw new Error(`Bidding does not exist`);
        }
        // 新增一筆招標單
        let bidding = JSON.parse(bidding_AsBytes.toString());
        bidding['record'].push(JSON.parse(new_bidding));
        // 更新帳本
        await ctx.stub.putState('bidding', Buffer.from(JSON.stringify(bidding)));
    }

    // 取得上鏈的招標單資料
    async query_bidding(ctx) {
        // 取得目前上鏈的招標單
        const bidding_AsBytes = await ctx.stub.getState('bidding');
        if (!bidding_AsBytes || bidding_AsBytes.length === 0) {
            throw new Error(`Bidding does not exist`);
        }
        // 回傳結果
        return bidding_AsBytes.toString();
    }

    // 決標單上鏈
    async submit_award(ctx, new_award) {
        // 取得目前上鏈的決標單
        const award_AsBytes = await ctx.stub.getState('award');
        if (!award_AsBytes || award_AsBytes.length === 0) {
            throw new Error(`Award does not exist`);
        }
        // 新增一筆決標單
        let award = JSON.parse(award_AsBytes.toString());
        award['record'].push(JSON.parse(new_award));
        // 更新帳本
        await ctx.stub.putState('award', Buffer.from(JSON.stringify(award)));
    }

    // 取得上鏈的決標單資料
    async query_award(ctx) {
        // 取得目前上鏈的決標單
        const award_AsBytes = await ctx.stub.getState('award');
        if (!award_AsBytes || award_AsBytes.length === 0) {
            throw new Error(`Award does not exist`);
        }
        // 回傳結果
        return award_AsBytes.toString();
    }

}

module.exports = Bidding;
