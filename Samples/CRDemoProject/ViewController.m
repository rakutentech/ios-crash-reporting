#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)exceptionButton:(id)sender {
    @throw([NSException exceptionWithName:@"Testing NSException"
                                   reason:@"Testing NSException"
                                 userInfo:nil]);
}

- (IBAction)sigabrtButton:(id)sender {
    abort();
}

- (IBAction)sigsegvButton:(id)sender {
    kill(getpid(), SIGSEGV);
}

- (IBAction)sigillButton:(id)sender {
    kill(getpid(), SIGILL);
}

- (IBAction)sigfpeButton:(id)sender {
    kill(getpid(), SIGFPE);
}

- (IBAction)sigpipeButton:(id)sender {
    raise(SIGPIPE);
}

- (IBAction)sigbusButton:(id)sender {
    raise(SIGBUS);
}

- (IBAction)badAccess:(id)sender {
    strcpy(0,"BadAccess");
}

@end
