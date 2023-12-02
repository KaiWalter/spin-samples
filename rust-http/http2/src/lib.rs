use anyhow::Result;
use spin_sdk::{
    http::{IntoResponse, Json, Params, Request, Response, Router},
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
    let dapr_port_var = variables::get("dapr_url")?;

    println!("name: {}", req.body().name);
    println!("port_var: {}", dapr_port_var);

    Ok(Response::new(200, format!("name: {}", req.body().name)))
}
