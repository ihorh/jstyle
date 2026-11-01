# Run the benchmark tasks in fresh `claude -p` sessions and record the outputs.
#
#   make -j4 MODEL=claude-opus-5-5                  baseline, 3 samples per task
#   make -j4 MODEL=claude-opus-5-5 CONDITION=both   with and without the skill
#   make -j4 MODEL=claude-opus-5-5 RUN=runs/<dir>   resume: only missing outputs
#   make stats RUN=runs/<folder>            tokens, time, and turns per task
#
# Each output file is a target, so a rerun skips the ones already written. Add
# -k to keep going past a failed session. lib/session.sh runs one session, and
# lib/manifest.sh records what ran.

MODEL     ?=
CONDITION ?= base
SAMPLES   ?= 3
EFFORT    ?=
RUN       ?= runs/$(shell date +%F)-$(MODEL)
PLUGIN    := $(abspath ../plugins/jstyle)

# `make stats RUN=...` needs neither a model nor clean inputs.
ifneq ($(MAKECMDGOALS),stats)
# A full model ID, never an alias: an alias like `opus` moves when a model ships.
ifeq ($(filter claude-%,$(MODEL)),)
$(error MODEL must be a full model ID, for example: make -j4 MODEL=claude-opus-5-5)
endif
endif

CONDS := $(if $(filter both,$(CONDITION)),base skill,$(CONDITION))
TASKS := $(notdir $(wildcard tasks/*))

# The manifest names the commit of world/ and tasks/, so they must be committed.
DIRTY := $(if $(shell git status --porcelain -- world tasks),true,false)
ifneq ($(MAKECMDGOALS),stats)
ifeq ($(DIRTY)$(ALLOW_DIRTY),true)
$(error world/ or tasks/ has uncommitted changes. Commit them, or set ALLOW_DIRTY=1)
endif
endif

export MODEL EFFORT PLUGIN CONDS SAMPLES TASKS DIRTY

OUTS := $(foreach t,$(TASKS),$(foreach c,$(CONDS),$(foreach n,$(shell seq 1 $(SAMPLES)),\
          $(RUN)/outputs/$(t)/$(c)-$(n).md)))

.PHONY: run stats
run: $(OUTS)
	@echo "results: $(RUN)"

# The stem is "<task>/<condition>-<n>": $(*D) is the task, and the condition
# leads $(*F).
$(RUN)/outputs/%.md: | $(RUN)/manifest.json
	@lib/session.sh $(*D) $(firstword $(subst -, ,$(*F))) $@

$(RUN)/manifest.json:
	@lib/manifest.sh $@

# Mean tokens, time, and turns per task and condition: make stats RUN=runs/<folder>
stats:
	@lib/stats.sh $(RUN)
