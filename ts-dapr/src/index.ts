import {
  HandleRequest,
  HttpRequest,
  HttpResponse,
  Router,
  Config,
} from "@fermyon/spin-sdk";

const encoder = new TextEncoder();
const decoder = new TextDecoder();
const router = Router();

router.get("/healthz", () => ({ status: 200 }));
router.options("/q-order-ingress", () => ({ status: 200 }));
router.post("/q-order-ingress", ({}, body) => messageHandler(body));
router.all("*", () => ({
  status: 404,
  body: encoder.encode("Not found"),
}));

async function messageHandler(body: ArrayBuffer): Promise<HttpResponse> {
  try {
    const order = JSON.parse(decoder.decode(body));
    console.log(order);

    const dapr_url = Config.get("dapr_url");
    console.log(dapr_url);
    const url = `${dapr_url}/v1.0/bindings/q-order-${order.delivery}`;
    console.log(url);

    let result = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: encoder.encode(
        JSON.stringify(
          {
            operation: "create",
            data: order,
          },
          null,
          2,
        ),
      ),
    });

    console.log("after fetch");

    return {
      status: 200,
      body: encoder.encode(JSON.stringify(order, null, 2)),
    };
  } catch (e) {
    return {
      status: 500,
      body: encoder.encode("internal error"),
    };
  }
}

export const handleRequest: HandleRequest = async function (
  request: HttpRequest,
): Promise<HttpResponse> {
  return router.handleRequest(request, request.body);
};
