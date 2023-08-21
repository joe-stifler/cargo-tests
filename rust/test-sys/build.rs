use std::env;
use std::fs::File;
use std::io::copy;
use std::path::PathBuf;
use std::process::Command;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    if !cfg!(target_os = "linux") {
        panic!("Unsupported OS. Only Linux is supported.");
    }

    if !cfg!(target_arch = "x86_64") {
        panic!("Unsupported architecture. Only x86_64 is supported.");
    }

    const LIB_NAME: &'static str = "api"; // TODO: update this to `blitzar
    const SHARED_LIB: &'static str = "libapi.so"; // TODO: update this to `libblitzar.so`
    const REPO_NAME: &'static str = "cargo-tests"; // TODO: update this to `blitzar`
    const REPO_OWNER: &'static str = "joe-stifler"; // TODO: update this to `spaceandtimelabs`
    const PKG_VERSION: &'static str = env!("CARGO_PKG_VERSION");

    let out_dir = PathBuf::from(env::var("OUT_DIR")?);
    let lib_path = out_dir.join(SHARED_LIB); // TODO: update this to `libblitzar.so`

    if PKG_VERSION == "0.0.0" {
        assert!(Command::new("bash")
            .current_dir("../../")
            .arg("ci/build.sh")
            .arg(&lib_path)
            .arg("0.0.0")
            .status()
            .expect("Failed to run the build script")
            .success()
        );
    } else {
        let mut lib_file = File::create(&lib_path)?;
        let release_url = format!("http://github.com/{REPO_OWNER}/{REPO_NAME}/releases/download/{PKG_VERSION}/{SHARED_LIB}");
        let mut response = reqwest::blocking::get(release_url)?;
        copy(&mut response, &mut lib_file)?;

        println!("cargo:rerun-if-changed=build.rs");
    }

    println!("cargo:rerun-if-env-changed=CARGO_PKG_VERSION");
    println!("cargo:rustc-link-search=native={}", out_dir.display());
    println!("cargo:rustc-link-lib=dylib={LIB_NAME}"); // TODO: update this to `blitzar`

    Ok(())
}
