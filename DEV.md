# Developer notes

> Every pushed tag (vx.y.z) is automatically released.

## New version

* Update the version that is reported in the template (resource `MonitoringJumpStartEvent`.).
* In the marbot code base, update the latest version in `data/jumpstart.js` as well.
* Push to master.
* Create a new tag (vx.y.z) and push.

## New Module

If you add a new module:

* In the marbot code base, add the latest version to `data/jumpstart.js`.
* In the marbot code base, add the module to `lib/nav.js`.
* Push to master.
* Create a new tag (vx.y.z) and push.
* [Publish to the Terraform Registry](https://www.terraform.io/docs/registry/modules/publish.html).
* Consider to port it to CloudFormation as well.
