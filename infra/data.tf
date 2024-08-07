# Make archive of function to upload on AWS lambda 
data "archive_file" "zip"{
    type = "zip"
    source_dir = "${path.module}/lambda"
    output_path = "${path.module}/packedlambda.zip"
}