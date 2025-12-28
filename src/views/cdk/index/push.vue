<template>
  <div class="ele-body">
    <!-- tabs -->
    <el-tabs v-model="where.pushType" type="card" @tab-click="onTabsChange">
      <el-tab-pane label="首页" name="1">
        <ProjectsTable ref="table1" project-type="1" push-type="1" @rowEdit="openEdit" />
      </el-tab-pane>
      <el-tab-pane label="爱心捐赠" name="2">
        <ProjectsTable ref="table2" project-type="2" push-type="2" @rowEdit="openEdit" />
      </el-tab-pane>
    </el-tabs>
    <!-- 详情弹窗 -->
    <projects-detail
      v-if="showEdit && showType==='detail'"
      @close="showEdit=false"
      :data="current"
      :visible="showEdit"
      @done="reload"/>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import ProjectsDetail from './project-detail';
import ProjectsTable from './components/push-card';
import regions from 'ele-admin/packages/regions';

export default {
  name: 'CfProjectsPush',
  components: {ProjectsTable, ProjectsDetail},
  computed: {
    ...mapGetters(["permission"]),
  },
  data() {
    return {
      // 省市区数据
      regions: regions,
      // 表格搜索条件
      where: {
        pushType: '1'
      },
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
      if (this.where.pushType === '1') {
        this.$refs.table1.reload();
      } else {
        this.$refs.table2.reload();
      }
    },
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
    /* 删除 */
    // remove(row) {
    //   const loading = this.$loading({lock: true});
    //   this.$http.post('/cfProjects/delete', [row.id]).then(res => {
    //     loading.close();
    //     if (res.data.code === 200) {
    //       this.$message.success(res.data.message);
    //       this.reload();
    //     } else {
    //       this.$message.error(res.data.message);
    //     }
    //   }).catch(e => {
    //     loading.close();
    //     this.$message.error(e.message);
    //   });
    // },
    /* 批量删除 */
    // removeBatch() {
    //   if (!this.selection.length) {
    //     this.$message.error('请至少选择一条数据');
    //     return;
    //   }
    //   this.$confirm('确定要删除选中的项目吗?', '提示', {
    //     type: 'warning'
    //   }).then(() => {
    //     const loading = this.$loading({lock: true});
    //     this.$http.post('/cfProjects/delete', this.selection.map(d => d.id)).then(res => {
    //       loading.close();
    //       if (res.data.code === 200) {
    //         this.$message.success(res.data.message);
    //         this.reload();
    //       } else {
    //         this.$message.error(res.data.message);
    //       }
    //     }).catch(e => {
    //       loading.close();
    //       this.$message.error(e.message);
    //     });
    //   }).catch(() => {
    //   });
    // },
    /* 更改状态 */
    // editStatus(row) {
    //   const loading = this.$loading({lock: true});
    //   let params = Object.assign({
    //     "id": row.id,
    //     "status": row.status
    //   })
    //   this.$http.post('/cfProjects/status', params).then(res => {
    //     loading.close();
    //     if (res.data.code === 200) {
    //       this.$message.success(res.data.message);
    //     } else {
    //       row.status = !row.status ? 1 : 2;
    //       this.$message.error(res.data.message);
    //     }
    //   }).catch(e => {
    //     loading.close();
    //     this.$message.error(e.message);
    //   });
    // },
  }
}
</script>

<style scoped>
.ele-form-search >>> .ele-fluid .el-range-input {
  width: 100%;
}
</style>
