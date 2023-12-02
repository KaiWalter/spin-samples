import { HandleRequest, HttpRequest, HttpResponse, Router } from "@fermyon/spin-sdk"

const encoder = new TextEncoder()
const decoder = new TextDecoder()
const router = Router()

router.get("/healthz", () => ({ status: 200 }))
router.options("/q-order-ingress", () => ({ status: 200 }))
router.post("/q-order-ingress", ({ }, body) => formatJson(body))
router.all("*", () => ({
    status: 404,
    body: encoder.encode("Not found")
}))

function formatJson(body: ArrayBuffer): HttpResponse {
    try {
        const json = JSON.parse(decoder.decode(body))
        console.log(json); 
        return {
            status: 200,
            body: encoder.encode(JSON.stringify(json, null, 2))
        }
    } catch (e) {
        return {
            status: 400,
            body: encoder.encode("Invalid JSON provided, sorry!")
        }
    }
}

export const handleRequest: HandleRequest = async function (request: HttpRequest): Promise<HttpResponse> {
    return router.handleRequest(request, request.body)
}
