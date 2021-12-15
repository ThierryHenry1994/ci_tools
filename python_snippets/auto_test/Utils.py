import canoe
import time
import fire

def do_event(cfg, tse):
    app = canoe.CanoeSync()
    app.Load(cfg)
    time.sleep(4)
    app.LoadTestSetup(tse)
    time.sleep(4)
    app.Start()
    time.sleep(5)
    # runs the test modules
    app.RunTestModules()
    time.sleep(5)
    app.Stop()
    time.sleep(4)

fire.Fire(do_event)