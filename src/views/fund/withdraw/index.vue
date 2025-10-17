<template>
  <div class="ele-body">
    <!-- tabs -->
    <el-tabs v-model="where.projectType" type="card" @tab-click="onTabsChange">
      <el-tab-pane label="个人筹款" name="1">
        <ProjectsTable ref="table1" project-type="1" @rowEdit="openEdit" />
      </el-tab-pane>
      <el-tab-pane label="公益组织" name="2">
        <ProjectsTable ref="table2" project-type="2" @rowEdit="openEdit" />
      </el-tab-pane>
    </el-tabs>
    <!-- 详情弹窗 -->
    <withdraw-detail
      v-if="showEdit && showType==='detail'"
      @close="showEdit=false"
      :data="current"
      :visible="showEdit"
      @done="reload"/>
    <!-- 历史弹窗 -->
    <withdraw-history
      v-if="showEdit && showType==='history'"
      @close="showEdit=false"
      :data="current"
      :visible="showEdit"
      @done="reload"/>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import WithdrawDetail from './withdraw-detail';
import WithdrawHistory from './withdraw-history';
import ProjectsTable from './components/withdraw-card';
import regions from 'ele-admin/packages/regions';

export default {
  name: 'CfProjectsWithdraw',
  components: {ProjectsTable, WithdrawDetail, WithdrawHistory},
  computed: {
    ...mapGetters(["permission"]),
  },
  data() {
    return {
      // 省市区数据
      regions: regions,
      // 表格数据接口
      url: '/cfProjectsWithdraw/index',
      // 表格搜索条件
      where: {
        projectType: '1'
      },
      // 表格选中数据
      selection: [],
      // 当前编辑数据
      current: null,
      // 是否显示编辑弹窗
      showType: 'detail',
      showEdit: false,

    };
  },
  mounted() {
  },
  methods: {
    /* 刷新表格 */
    reload() {
      this.showEdit = false;
      if (this.where.projectType === '1') {
        this.$refs.table1.reload();
      } else {
        this.$refs.table2.reload();
      }
    },
    /* 重置搜索 */
    // reset() {
    //   this.where = {projectType: this.where.projectType};
    //   this.reload();
    // },
    onTabsChange() {
      this.reload();
    },
    /* 显示编辑 */
    openEdit(data) {
      const {row, type} = data;
      this.current = row == null ? {status: 1} : row;
      this.showType = type;
      this.showEdit = true;
    },
  }
}
</script>

<style scoped>
.ele-form-search >>> .ele-fluid .el-range-input {
  width: 100%;
}
</style>
