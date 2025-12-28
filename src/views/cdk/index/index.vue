<template>
  <div class="ele-body">
    <!-- tabs -->
    <el-tabs
      v-model="where.projectType"
      type="card"
      @tab-click="onProjectTypeChange"
    >
      <el-tab-pane
        label="个人筹款"
        name="1"
        v-if="this.$store.state.fund.fundList.length > 1"
      >
        <ProjectsTable ref="tablePerson" project-type="1" @rowEdit="openEdit" />
      </el-tab-pane>
      <el-tab-pane label="CDK列表" name="2">
        <ProjectsTable
          ref="tableOrganization"
          project-type="2"
          @rowEdit="openEdit"
        />
      </el-tab-pane>
    </el-tabs>

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
import regions from "ele-admin/packages/regions";

export default {
  name: "CfProjects",
  components: { ProjectsTable, ProjectsDetail, ProjectsEdit },
  computed: {
    ...mapGetters(["permission", "fundList"]),
  },
  watch: {
    fundList: {
      handler(newVal) {
        if (newVal) {
          // fundList 已加载，执行你的逻辑
          console.log("watch 到 fundList:", newVal);
          if (newVal != null) {
            this.fundList = newVal;
            this.where.fundIds =
              this.fundList.map((item) => item.id).join(",") || null;
            this.reload();
          }
        }
      },
      immediate: true, // 页面加载时立即触发一次
    },
  },
  data() {
    return {
      // 省市区数据
      regions: regions,
      // 表格数据接口
      url: "/cdk/index",
      // 表格列配置
      // 表格搜索条件
      where: {
        projectType: this.$store.state.fund.fundList > 1 ? "1" : "2",
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
      console.log("=>>>>>>", this.where);
      if (
        this.where.projectType === "1" &&
        this.$store.state.fund.fundList.length > 1
      ) {
        this.$refs.tablePerson.reload();
      } else {
        console.log("=>>>>>>", this.where);
        this.$refs.tableOrganization.reload({where: this.where});
      }
      // this.$refs.table.reload({where: this.where});
    },
    /* 重置搜索 */
    // reset() {
    //   this.where = {projectType: this.where.projectType};
    //   this.reload();
    // },
    onProjectTypeChange() {
      this.reload();
    },
    /* 显示编辑 */
    openEdit(data) {
      const { row, type } = data;
      console.log("-------", data);
      this.current = row;
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
  },
};
</script>

<style scoped>
.ele-form-search >>> .ele-fluid .el-range-input {
  width: 100%;
}
</style>
