use spin_sdk::http::{IntoResponse, Request};
use spin_sdk::http_component;

#[http_component]
fn handle_http1(req: Request) -> anyhow::Result<impl IntoResponse> {
    println!("Handling request to {:?}", req.header("spin-full-url"));
    Ok(http::Response::builder()
        .status(200)
        .header("content-type", "text/plain")
        .body("Ingress")?)
}
