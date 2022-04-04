package hacbs.contract.transparency_urls

tr = {
  "apiVersion": "tekton.dev/v1beta1",
  "kind": "TaskRun",
  "metadata": {
    "annotations": {
      "chains.tekton.dev/signed": "true",
      "chains.tekton.dev/transparency": "https://rekor.sigstore.dev/api/v1/log/entries?logIndex=1884597",
    }
  }
}

cm = {
  "chains-config": {
    "data": {
      "transparency.enabled": "true"
    }
  }
}

test_annotations_present {
  count(deny) == 0 with data.k8s.ConfigMap as cm with data.k8s.TaskRun.fake_tr as tr
}

test_annotation_unsigned {
  metadata := object.union(tr, {"metadata": {"annotations": {"chains.tekton.dev/signed": "false"}}})
  count(deny) == 1 with data.k8s.ConfigMap as cm with data.k8s.TaskRun.fake_tr as metadata
}

test_annotation_different_transparency_url {
  metadata := {
    "one": tr,
    "two": object.union(tr, {"metadata": {"annotations": {"chains.tekton.dev/transparency": "https://rekor.sigstore.local"}}})
  }
  count(deny) == 1 with data.k8s.ConfigMap as cm with data.k8s.TaskRun as metadata
}

test_cm_transparency_disabled {
  cm := {
    "chains-config": {
      "data": {
        "transparency.enabled": "false"
      }
    }
  }
  count(deny) == 1 with data.k8s.ConfigMap as cm with data.k8s.TaskRun.fake_tr as tr
}
