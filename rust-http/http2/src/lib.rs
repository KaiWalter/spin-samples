use anyhow::Result;
use spin_sdk::{
    http::{
        IncomingResponse, IntoResponse, Json, Method, Params, Request, RequestBuilder, Response,
        Router,
    },
    http_component, variables,
};

#[derive(serde::Deserialize, Debug)]
struct Order {
    name: String,
}

#[http_component]
fn handle_route(req: Request) -> Response {
    let mut router = Router::new();
    router.get("/health", health);
    router.post("/q-order-ingress", ingress);
    router.handle(req)
}

fn health(_req: Request, _params: Params) -> Result<impl IntoResponse> {
    Ok(Response::new(200, format!("Healthy")))
}

fn ingress(req: http::Request<Json<Order>>, _params: Params) -> Result<impl IntoResponse> {
    let dapr_url = variables::get("dapr_url")?;

    println!("name: {}", req.body().name);
    println!("dapr_url: {}", dapr_url);

    // let body = bytes::Bytes::from(json!({ "name": "test" }).to_string());
    // let url = format!("{}/v1.0/bindings/q-order-standard", dapr_url);
    // let res = spin_sdk::http::send(Request::post(url, Some(body)));
    //
    // let request = RequestBuilder::new(Method::Post, "/v1.0/bindings/q-order-standard")
    //     .uri(dapr_url)
    //     .method(Method::Post)
    //     .body("Hello, world!")
    //     .build();
    //
    // let _response: IncomingResponse = spin_sdk::http::send(request).await?;

    Ok(Response::new(200, format!("name: {}", req.body().name)))
}
