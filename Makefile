GITLAB_SHELL ?= /usr/share/gitlab-shell/bin/gitlab-shell
GITLAB_USER  ?= gitlab
GITLAB_GROUP ?= gitlab

BINDIR           ?= /usr/local/bin
SD_SYSTEMUNITDIR != pkg-config --variable=systemdsystemunitdir systemd
CPPFLAGS         += -DGITLAB_SHELL=$(GITLAB_SHELL)

.PHONY: all
all: gitlab-pivot
	@printf '%s\n' \
	  'GITLAB_SHELL = $(GITLAB_SHELL)' \
	  'Make sure that GITLAB_SHELL is set correctly.' \
	  'To install gitlab-pivot, use:' \
	  '`make GITLAB_USER=... GITLAB_GROUP=... gitlab-pivot-install`'

.PHONY: install gitlab-groupsync-install gitlab-pivot-install
install: gitlab-groupsync-install gitlab-pivot-install

gitlab-groupsync-install: gitlab-groupsync gitlab-groupsync.service
	install --mode=755 -D --target-directory=$(DESTDIR)$(BINDIR) $<
	install --mode=644 -D --target-directory=$(DESTDIR)$(SD_SYSTEMUNITDIR) $(lastword $^)
	sed -i -e 's|/usr/local/bin|$(BINDIR)|g' $(DESTDIR)$(SD_SYSTEMUNITDIR)/$(lastword $^)

gitlab-pivot-install: gitlab-pivot
	install --mode=6755 --owner=$(GITLAB_USER) --group=$(GITLAB_GROUP) -D --target-directory=$(DESTDIR)$(BINDIR) $<

.PHONY: clean
clean:
	@rm -vf gitlab-pivot
