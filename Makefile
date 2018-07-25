
SCALA_VERSION := 2.11
PKG_DIR := ypackage
TGT_DIR := target
BASE_DIST_VERSION := $(shell cat $(PKG_DIR)/BASE_DIST_VERSION)
NEW_DIST_VERSION := $(shell /home/y/bin/auto_increment_version.pl yspark_yarn_avro $(BASE_DIST_VERSION) | awk '{print $1}')

define ignore-working-tree-changes
git ls-files -z | xargs --null git update-index --assume-unchanged
endef

define unignore-working-tree-changes
git ls-files -z | xargs --null git update-index --no-assume-unchanged
endef

platforms:
	echo "$(NEW_DIST_VERSION)" > $(PKG_DIR)/NEW_DIST_VERSION
	sbt clean package
	mv $(TGT_DIR)/scala-$(SCALA_VERSION)/spark-avro_$(SCALA_VERSION)-$(BASE_DIST_VERSION).jar $(TGT_DIR)/scala-$(SCALA_VERSION)/spark-avro_$(SCALA_VERSION)-$(NEW_DIST_VERSION).jar 

cleanplatforms:
	@echo "Skipping clean"

package:
	$(ignore-working-tree-changes)
	(unset PLATFORM && cd $(PKG_DIR) && yinst_create --buildtype release spark_yarn_avro.yicf)
	mkdir -p ${SRC_DIR}/target
	cp ypackage/*tgz ${SRC_DIR}/target
	$(unignore-working-tree-changes)

git_tag: build_description
		git tag -f -a `dist_tag list yspark_yarn_avro_4_0_latest  | cut -d '-' -f 2 | cut -d ' ' -f 1` -m "yahoo version `dist_tag list  yspark_yarn_avro_4_0_latest | cut -d '-' -f 2 | cut -d ' ' -f 1`"
			git push origin `dist_tag list yspark_yarn_avro_4_0_latest | cut -d '-' -f 2 | cut -d ' ' -f 1`

build_description:
	@echo "Build Description: `dist_tag list yspark_yarn_avro_4_0_latest | cut -d ' ' -f 1`"
