use anyhow::Result;
use spin_sdk::{
    http::{IntoResponse, Params, Request, Response, Router, Json},
    http_component,
};

#[derive(serde::Deserialize, Debug)]
struct Greeted {
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

fn ingress(req: http::Request<Json<Greeted>>, _params: Params) -> Result<impl IntoResponse> {
    Ok(Response::new(200, format!("name: {}",req.body().name)))
}    
