/*
Copyright 2019 The xridge kubestone contributors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package fio

import (
	"fmt"

	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

	perfv1alpha1 "github.com/xridge/kubestone/api/v1alpha1"
)

// NewConfigMap creates a new configmap for the fio benchmark job
func NewConfigMap(cr *perfv1alpha1.Fio) *corev1.ConfigMap {

	data := make(map[string]string)

	for i, customJobFile := range cr.Spec.CustomJobFiles {
		key := CustomJobName(i)
		data[key] = customJobFile
	}

	configMap := corev1.ConfigMap{
		ObjectMeta: metav1.ObjectMeta{
			Name:      cr.Name,
			Namespace: cr.Namespace,
		},
		Data: data,
	}

	return &configMap
}

// CustomJobName returns the key of the custom job file with the given index in the config map
func CustomJobName(index int) string {
	return fmt.Sprintf("customJob%d", index)
}
