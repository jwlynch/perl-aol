
#include "logging.h"

int main()
{
  LOG(StringF("format %s\n", "string"));
  LOG(StringF("%d %d %d %d %d \n", 1,2,3,4,5));

  return 0;
}
