#include "cpu.h"
#include "sketchybar.h"

struct cpu g_cpu;

void handler(env env) {
  char* name = env_get_value_for_key(env, "NAME");

  if ((strcmp(name, "cpu.percent") == 0)) {
    // CPU graph updates
    cpu_update(&g_cpu);

    if (strlen(g_cpu.command) > 0) sketchybar(g_cpu.command);
  }
}

int main (int argc, char** argv) {
  cpu_init(&g_cpu);

  if (argc < 2) {
    printf("Usage: helper \"<bootstrap name>\"\n");
    exit(1);
  }

  event_server_begin(handler, argv[1]);
  return 0;
}
