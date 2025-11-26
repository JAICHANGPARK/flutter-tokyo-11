use image::{load_from_memory, ImageFormat};
use std::io::Cursor;

use flutter_rust_bridge::frb;
use std::thread;
use std::time::Duration;

#[frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

#[frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

// 1. [Good] 기본 모드 (Async)
// FRB가 자동으로 Dart에는 Future를 반환하고,
// Rust 실행은 별도 스레드 풀에서 수행합니다.
pub fn rust_heavy_work_async() -> String {
    // 3초간 잠자기 (무거운 작업 시뮬레이션)
    thread::sleep(Duration::from_secs(5));
    "Async 작업 완료! (UI 살아있음)".to_string()
}

// 2. [Bad] 강제 동기 모드 (Sync)
// #[frb(sync)]를 붙이면 Dart의 메인 스레드에서 이 함수를 직접 호출합니다.
// 즉, 이 함수가 끝날 때까지 Dart(UI)도 멈춥니다.
#[frb(sync)]
pub fn rust_heavy_work_sync() -> String {
    // 3초간 잠자기
    thread::sleep(Duration::from_secs(5));
    "Sync 작업 완료! (앱 멈췄었음)".to_string()
}

// Dart에서 호출할 함수
// 입력: 이미지 바이트 배열 (Uint8List)
// 출력: 처리된 이미지 바이트 배열
pub fn process_image_heavy(image_data: Vec<u8>) -> Vec<u8> {
    // 1. 메모리에서 이미지 디코딩 (무거운 작업)
    let img = load_from_memory(&image_data).expect("이미지 형식이 잘못되었습니다.");

    // 2. 이미지 처리 (CPU 많이 씀)
    // 흑백으로 변환하고, 흐림 효과(Blur)를 줍니다.
    let processed_img = img.grayscale().blur(5.0);

    // 3. 다시 바이트로 인코딩 (무거운 작업)
    let mut result_bytes: Vec<u8> = Vec::new();
    processed_img
        .write_to(&mut Cursor::new(&mut result_bytes), ImageFormat::Png)
        .expect("인코딩 실패");

    // 결과 반환
    result_bytes
}

// 공통 로직: CPU를 많이 쓰는 무거운 작업 (블러 처리)
fn heavy_image_logic(image_data: Vec<u8>) -> Vec<u8> {
    // 1. 디코딩
    let img = load_from_memory(&image_data).expect("Image Load Failed");

    thread::sleep(Duration::from_secs(5));
    // 2. 무거운 처리 (Blur 20.0은 꽤 무겁습니다)
    // CPU가 행렬 계산하느라 1~3초 정도 걸립니다.
    let processed = img.blur(20.0);

    // 3. 인코딩
    let mut result = Vec::new();
    processed
        .write_to(&mut Cursor::new(&mut result), ImageFormat::Png)
        .unwrap();

    result
}

// [Safe] 비동기 함수 (기본)
// Dart에서는 Future<Uint8List>를 반환합니다.
// Rust 스레드 풀에서 실행되므로 UI를 막지 않습니다.
pub fn apply_filter_async(image_data: Vec<u8>) -> Vec<u8> {
    heavy_image_logic(image_data)
}

// [Danger] 동기 함수 (강제)
// Dart 메인 스레드가 이 함수를 직접 호출하고, 끝날 때까지 기다립니다.
// Thread Merge 환경에서 이걸 쓰면 앱이 죽습니다.
#[frb(sync)]
pub fn apply_filter_sync(image_data: Vec<u8>) -> Vec<u8> {
    heavy_image_logic(image_data)
}
