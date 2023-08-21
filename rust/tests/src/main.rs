extern crate test_sys;

pub fn add_from_library(a: i32, b: i32) -> i32 {
    unsafe { test_sys::add(a, b) }
}

pub fn subtract_from_library(a: i32, b: i32) -> i32 {
    unsafe { test_sys::subtract(a, b) }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_add_from_library() {
        let result = add_from_library(5, 3);
        assert_eq!(result, 8);
    }

    #[test]
    fn test_subtract_from_library() {
        let result = subtract_from_library(10, 3);
        assert_eq!(result, 7);
    }
}
