<template>
  <div class="ele-body">
    <ProjectsTable ref="tableOrganization" @rowEdit="openEdit" />

    <!-- 详情弹窗 -->
    <projects-detail
      v-if="showEdit && showType === 'detail'"
      @close="showEdit = false"
      :data="current"
      :visible="showEdit"
      @done="reload"
    />
    <!-- 编辑弹窗 -->
    <projects-edit
      v-if="showEdit && showType === 'edit'"
      @close="showEdit = false"
      :data="current"
      :visible="showEdit"
      @done="reload"
    />
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import ProjectsDetail from "./project-detail";
import ProjectsEdit from "./project-edit";
import ProjectsTable from "./components/project-card";

export default {
  name: "CfProjects",
  components: { ProjectsTable, ProjectsDetail, ProjectsEdit },
  computed: {
    ...mapGetters(["permission"]),
  },
  watch: {},
  data() {
    return {
      // 表格搜索条件
      where: {
      },
      // 表格选中数据
      selection: [],
      // 当前编辑数据
      current: null,
      // 是否显示编辑弹窗
      showType: "edit",
      showEdit: false,
      // 栏目列表
      cateList: [],
    };
  },
  mounted() {},
  methods: {
    /* 刷新表格 */
    reload() {
      this.showEdit = false;
      this.$refs.tableOrganization.reload({ where: this.where });
    },
    /* 显示编辑 */
    openEdit(data) {
      const { row, type } = data;
      this.current = row;
      this.showType = type;
      this.showEdit = true;
    },
  },
};
</script>

<style scoped>
.ele-form-search >>> .ele-fluid .el-range-input {
  width: 100%;
}
</style>
