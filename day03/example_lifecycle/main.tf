resource local_file "example" {

  content  = "Hello, World! with changes in lifecycle"
  filename = "example_lifecycle_create_before_destroy.txt"
  lifecycle {
    create_before_destroy = true
  }
}

resource local_file "example_prevent_destroy" {

  content  = "Hello, World! this will not be destroyed_even_if_content_changes"
  filename = "example_lifecycle_prevent_destroy.txt"
  lifecycle {
    prevent_destroy = true
  }
}