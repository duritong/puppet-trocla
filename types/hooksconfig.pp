# the trocla hooks config options
type Trocla::HooksConfig = Struct[{
  set    => Optional[Hash[String, Stdlib::Unixpath]],
  delete => Optional[Hash[String, Stdlib::Unixpath]],
}]
