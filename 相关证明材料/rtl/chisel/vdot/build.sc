import mill._
import scalalib._









object vdot extends ScalaModule {
  def scalaVersion = "2.13.15"
  def ivyDeps = Agg(
    ivy"org.chipsalliance::chisel:6.7.0"
  )
  def scalacPluginIvyDeps = Agg(
    ivy"org.chipsalliance:::chisel-plugin:6.7.0"
  )
}
