// +build !ignore_autogenerated_openshift

// This file was autogenerated by deepcopy-gen. Do not edit it manually!

package api

import (
	conversion "k8s.io/apimachinery/pkg/conversion"
	runtime "k8s.io/apimachinery/pkg/runtime"
	reflect "reflect"
)

func init() {
	SchemeBuilder.Register(RegisterDeepCopies)
}

// RegisterDeepCopies adds deep-copy functions to the given scheme. Public
// to allow building arbitrary schemes.
func RegisterDeepCopies(scheme *runtime.Scheme) error {
	return scheme.AddGeneratedDeepCopyFuncs(
		conversion.GeneratedDeepCopyFunc{Fn: DeepCopy_api_RunOnceDurationConfig, InType: reflect.TypeOf(&RunOnceDurationConfig{})},
	)
}

// DeepCopy_api_RunOnceDurationConfig is an autogenerated deepcopy function.
func DeepCopy_api_RunOnceDurationConfig(in interface{}, out interface{}, c *conversion.Cloner) error {
	{
		in := in.(*RunOnceDurationConfig)
		out := out.(*RunOnceDurationConfig)
		*out = *in
		if in.ActiveDeadlineSecondsLimit != nil {
			in, out := &in.ActiveDeadlineSecondsLimit, &out.ActiveDeadlineSecondsLimit
			*out = new(int64)
			**out = **in
		}
		return nil
	}
}