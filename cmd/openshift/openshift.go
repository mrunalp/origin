package main

import (
	"os"
	"os/signal"
	"path/filepath"
	"syscall"

	"github.com/golang/glog"
	"github.com/openshift/origin/pkg/cmd/openshift"
	"github.com/openshift/origin/pkg/cmd/util/serviceability"
)

func main() {
	defer serviceability.BehaviorOnPanic(os.Getenv("OPENSHIFT_ON_PANIC"))()
	defer serviceability.Profile(os.Getenv("OPENSHIFT_PROFILE")).Stop()

	basename := filepath.Base(os.Args[0])
	command := openshift.CommandFor(basename)

	// Launch a reaper routine if we are pid 1 for e.g. openshift-router in a container.
	if os.Getpid() == 1 {
		go func() {
			sigs := make(chan os.Signal, 1)
			signal.Notify(sigs, syscall.SIGCHLD)
			for {
				sig := <-sigs
				glog.V(4).Infof("Signal received: %+v", sig)
				glog.V(4).Infof("Launching reaper")
				for {
					// Reap zombies
					glog.V(4).Infof("Waiting to reap")
					cpid, err := syscall.Wait4(-1, nil, 0, nil)
					if err == syscall.ECHILD {
						glog.V(4).Infof("Received: %+v", err)
						break
					}
					glog.V(4).Infof("Reaped process with pid %d", cpid)
				}
			}
		}()
	}

	if err := command.Execute(); err != nil {
		os.Exit(1)
	}
}
