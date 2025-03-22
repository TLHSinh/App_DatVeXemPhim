import crypto from "crypto";
import { default as axios } from "axios";
var accessKey = 'F8BBA842ECF85';
var secretKey = 'K951B6PE1waDMi640xX08PD3vg6EkVlz';
var partnerCode = 'MOMO';

export const createPayment = async (req, res) => {
    const { amount, orderInfo } = req.body;

    var redirectUrl = 'https://webhook.site/b3088a6a-2d17-4f8d-a383-71389a6c600b';
    var ipnUrl = 'https://2f91-2405-4802-9112-b2d0-e13b-696e-841c-e008.ngrok-free.app/api/v1/callback';
    var requestType = "payWithMethod";
    var orderId = partnerCode + new Date().getTime();
    var requestId = orderId;
    var extraData = '';
    var orderGroupId = '';
    var autoCapture = true;
    var lang = 'vi';
    var orderExpireTime = 30;

    var rawSignature = `accessKey=${accessKey}&amount=${amount}&extraData=${extraData}&ipnUrl=${ipnUrl}&orderId=${orderId}&orderInfo=${orderInfo}&partnerCode=${partnerCode}&redirectUrl=${redirectUrl}&requestId=${requestId}&requestType=${requestType}`;

    var signature = crypto.createHmac('sha256', secretKey)
        .update(rawSignature)
        .digest('hex');

    console.log("--------------------RAW SIGNATURE----------------")
    console.log(rawSignature);
    console.log("--------------------SIGNATURE----------------")
    console.log(signature);
    console.log("--------------------Expire Time----------------")
    console.log(orderExpireTime);

    const requestBody = {
        partnerCode,
        partnerName: "Test",
        storeId: "MomoTestStore",
        requestId,
        amount,
        orderId,
        orderInfo,
        redirectUrl,
        ipnUrl,
        lang,
        requestType,
        autoCapture,
        extraData,
        orderGroupId,
        signature,
        orderExpireTime
    };

    try {
        const result = await axios.post("https://test-payment.momo.vn/v2/gateway/api/create", requestBody, {
            headers: {
                'Content-Type': 'application/json'
            }
        });
        console.log("MoMo Response:", result.data);
        return res.status(200).json(result.data);
    } catch (error) {
        console.error(error);
        return res.status(500).json({
            statusCode: 500,
            message: "Server error"
        });
    }
};

export const callback = async (req, res) => {
    console.log("callback::");
    console.log(req.body);

    return res.status(200).json(req.body);
};

export const transactionStatus = async (req, res) => {
    const { orderId } = req.body;

    var rawSignature = `accessKey=${accessKey}&orderId=${orderId}&partnerCode=${partnerCode}&requestId=${orderId}`;

    const signature = crypto
        .createHmac("sha256", secretKey)
        .update(rawSignature)
        .digest('hex');

    const requestBody = JSON.stringify({
        partnerCode: "MOMO",
        requestId: orderId,
        orderId,
        signature,
        lang: 'vi'
    });

    try {
        const response = await axios.post(
            "https://test-payment.momo.vn/v2/gateway/api/query",
            requestBody,
            {
                headers: {
                    "Content-Type": "application/json",
                    "Content-Length": Buffer.byteLength(requestBody)
                }
            }
        );

        // Kiểm tra phản hồi từ MoMo
        if (response && response.data) {
            return res.status(200).json(response.data);
        } else {
            throw new Error("Không nhận được phản hồi từ MoMo");
        }
    } catch (error) {
        console.error("Lỗi khi gọi API MoMo:", error.response?.data || error.message);

        return res.status(500).json({
            statusCode: 500,
            message: "Lỗi khi thực hiện thanh toán",
            error: error.response?.data || error.message
        });
    }
};