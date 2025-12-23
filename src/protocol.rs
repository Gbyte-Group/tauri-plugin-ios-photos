use tauri::{
    http::{Request, Response},
    utils::mime_type::MimeType,
    Runtime, UriSchemeContext,
};

pub const CUSTOM_PROTOCOL: &'static str = "temp";

pub fn register_protocol<R: Runtime>(
    _ctx: UriSchemeContext<'_, R>,
    request: Request<Vec<u8>>,
) -> Response<Vec<u8>> {
    let path = request.uri().path();
    let full_path = format!("{}", &path);

    let mut response = Response::builder()
        .header("Access-Control-Allow-Origin", "*")
        .header("Access-Control-Allow-Methods", "*")
        .header("Access-Control-Allow-Headers", "*");

    let mut status_code = 200;

    let mut body: Vec<u8> = vec![];

    match std::fs::read(full_path) {
        Ok(data) => {
            response = response.header("Content-Type", MimeType::parse(&data, &path));
            body.extend(data);
        }
        Err(_) => {
            status_code = 404;
        }
    }

    response.status(status_code).body(body).unwrap()
}
