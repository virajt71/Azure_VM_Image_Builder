locals {
  # Build distribute array with only the fields needed for each type
  distribute_list = [
    for dist in var.distribute : merge(
      {
        type          = dist.type
        runOutputName = dist.runOutputName
        artifactTags  = dist.artifactTags
      },
      dist.galleryImageId != null ? { galleryImageId = dist.galleryImageId } : {},
      dist.targetRegions != null ? { targetRegions = dist.targetRegions } : {},
      dist.imageId != null ? { imageId = dist.imageId } : {},
      dist.location != null && dist.type == "ManagedImage" ? { location = dist.location } : {},
      dist.uri != null ? { uri = dist.uri } : {}
    )
  ]
}