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
      <el-tab-pane label="基金会" name="2">
        <ProjectsTable
          ref="tableOrganization"
          project-type="2"
          @rowEdit="openEdit"
        />
      </el-tab-pane>
    </el-tabs>

    <!--    <el-card shadow="never">-->
    <!-- 搜索表单 -->
    <!--      <el-form-->
    <!--        :model="where"-->
    <!--        label-width="77px"-->
    <!--        class="ele-form-search"-->
    <!--        @keyup.enter.native="reload"-->
    <!--        @submit.native.prevent>-->
    <!--        <el-row :gutter="15">-->
    <!--          <el-col :lg="6" :md="12">-->
    <!--            <el-form-item label="患者姓名:">-->
    <!--              <el-input-->
    <!--                clearable-->
    <!--                v-model="where.title"-->
    <!--                placeholder="请输入活患者姓名"/>-->
    <!--            </el-form-item>-->
    <!--          </el-col>-->
    <!--          <el-col :lg="6" :md="12">-->
    <!--            <el-form-item label="所在地区:">-->
    <!--              <el-cascader-->
    <!--                clearable-->
    <!--                v-model="where.city"-->
    <!--                class="ele-fluid"-->
    <!--                placeholder="请选择省市区"-->
    <!--                :options="regions.cityData"-->
    <!--                popper-class="ele-pop-wrap-higher"/>-->
    <!--            </el-form-item>-->
    <!--          </el-col>-->
    <!--          <el-col :lg="6" :md="12">-->
    <!--            <el-form-item label="筹款金额:">-->
    <!--              <el-row>-->
    <!--                <el-col :span="11">-->
    <!--                  <el-input-->
    <!--                    clearable-->
    <!--                    v-model="where.title"-->
    <!--                    placeholder="起"/>-->
    <!--                </el-col>-->
    <!--                <el-col :span="2" style="text-align: center">至</el-col>-->
    <!--                <el-col :span="11">-->
    <!--                  <el-input-->
    <!--                    clearable-->
    <!--                    v-model="where.title"-->
    <!--                    placeholder="止"/>-->
    <!--                </el-col>-->
    <!--              </el-row>-->
    <!--            </el-form-item>-->
    <!--          </el-col>-->
    <!--          <el-col :lg="6" :md="12">-->
    <!--            <el-form-item label="状态:">-->
    <!--              <el-select-->
    <!--                clearable-->
    <!--                v-model="where.status"-->
    <!--                placeholder="全部"-->
    <!--                class="ele-fluid">-->
    <!--                <el-option label="生效中" value="1"/>-->
    <!--                <el-option label="已停止" value="2"/>-->
    <!--              </el-select>-->
    <!--            </el-form-item>-->
    <!--          </el-col>-->
    <!--          <el-col :lg="6" :md="12">-->
    <!--            <el-form-item label="申请日期:">-->
    <!--              <el-date-picker-->
    <!--                v-model="where.dateRange"-->
    <!--                type="daterange"-->
    <!--                range-separator="至"-->
    <!--                start-placeholder="开始日期"-->
    <!--                end-placeholder="结束日期"-->
    <!--                class="ele-fluid">-->
    <!--              </el-date-picker>-->
    <!--            </el-form-item>-->
    <!--          </el-col>-->
    <!--          <el-col :lg="6" :md="12">-->
    <!--            <div class="ele-form-actions">-->
    <!--              <el-button-->
    <!--                type="primary"-->
    <!--                icon="el-icon-search"-->
    <!--                class="ele-btn-icon"-->
    <!--                @click="reload">查询-->
    <!--              </el-button>-->
    <!--              <el-button @click="reset">重置</el-button>-->
    <!--            </div>-->
    <!--          </el-col>-->
    <!--        </el-row>-->
    <!--      </el-form>-->
    <!-- 数据表格 -->
    <!--    </el-card>-->
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
      url: "/cfProjects/index",
      // 表格列配置
      columns: [
        // {
        //   columnKey: 'selection',
        //   type: 'selection',
        //   width: 45,
        //   align: 'center',
        //   fixed: "left"
        // },
        {
          prop: "id",
          label: "ID",
          width: 60,
          align: "center",
          showOverflowTooltip: true,
          fixed: "left",
        },
        {
          prop: "createdAt",
          label: "申请时间",
          sortable: "custom",
          showOverflowTooltip: true,
          minWidth: 160,
          align: "center",
          formatter: (row, column, cellValue) => {
            return this.$util.toDateString(cellValue);
          },
        },
        {
          prop: "patientRelation",
          label: "为谁筹款",
          showOverflowTooltip: true,
          minWidth: 150,
          align: "center",
        },
        {
          prop: "patientName",
          label: "患者姓名",
          showOverflowTooltip: true,
          minWidth: 150,
          align: "center",
        },
        {
          prop: "patientIdNo",
          label: "患者证件号",
          showOverflowTooltip: true,
          minWidth: 150,
          align: "center",
        },
        {
          prop: "disease",
          label: "所患疾病",
          showOverflowTooltip: true,
          minWidth: 200,
          align: "center",
        },
        {
          prop: "contactPhone",
          label: "手机号码",
          showOverflowTooltip: true,
          minWidth: 200,
          align: "center",
        },
        {
          prop: "city",
          label: "所在地区",
          showOverflowTooltip: true,
          minWidth: 200,
          align: "center",
          slot: "city",
        },
        {
          prop: "targetAmount",
          label: "筹款金额",
          showOverflowTooltip: true,
          minWidth: 200,
          align: "center",
        },
        {
          prop: "raisedAmount",
          label: "已筹金额",
          showOverflowTooltip: true,
          minWidth: 200,
          align: "center",
        },
        {
          prop: "economic",
          label: "经济情况",
          showOverflowTooltip: true,
          minWidth: 200,
          align: "center",
          slot: "economic",
        },
        // {
        //   prop: 'startAt',
        //   label: '开始时间',
        //   sortable: 'custom',
        //   showOverflowTooltip: true,
        //   minWidth: 160,
        //   align: 'center',
        //   formatter: (row, column, cellValue) => {
        //     return this.$util.toDateString(cellValue, 'yyyy-MM-dd');
        //   }
        // },
        // {
        //   prop: 'endAt',
        //   label: '截止时间',
        //   sortable: 'custom',
        //   showOverflowTooltip: true,
        //   minWidth: 160,
        //   align: 'center',
        //   formatter: (row, column, cellValue) => {
        //     return this.$util.toDateString(cellValue, 'yyyy-MM-dd');
        //   }
        // },
        {
          prop: "status",
          label: "状态",
          align: "center",
          width: 150,
          resizable: false,
          slot: "status",
        },
        {
          prop: "updatedAt",
          label: "审核时间",
          sortable: "custom",
          showOverflowTooltip: true,
          minWidth: 160,
          align: "center",
          formatter: (row, column, cellValue) => {
            return this.$util.toDateString(cellValue);
          },
        },
        {
          columnKey: "action",
          label: "操作",
          width: 150,
          align: "center",
          resizable: false,
          slot: "action",
          fixed: "right",
        },
      ],
      // 组织机构列表
      columns_org: [
        {
          prop: "id",
          label: "ID",
          width: 60,
          align: "center",
          showOverflowTooltip: true,
          fixed: "left",
        },
        {
          prop: "createdAt",
          label: "申请时间",
          sortable: "custom",
          showOverflowTooltip: true,
          minWidth: 160,
          align: "center",
          formatter: (row, column, cellValue) => {
            return this.$util.toDateString(cellValue);
          },
        },
        {
          prop: "organizationName",
          label: "组织机构名称",
          showOverflowTooltip: true,
          minWidth: 150,
          align: "center",
        },
        {
          prop: "contactPhone",
          label: "联系方式",
          showOverflowTooltip: true,
          minWidth: 200,
          align: "center",
        },
        {
          prop: "targetAmount",
          label: "筹款金额",
          showOverflowTooltip: true,
          minWidth: 200,
          align: "center",
        },
        {
          prop: "raisedAmount",
          label: "已筹金额",
          showOverflowTooltip: true,
          minWidth: 200,
          align: "center",
        },
        {
          prop: "startDate",
          label: "开始时间",
          showOverflowTooltip: true,
          minWidth: 200,
          align: "center",
          slot: "rangeDate",
        },
        {
          prop: "status",
          label: "状态",
          align: "center",
          width: 150,
          resizable: false,
          slot: "status",
        },
        {
          prop: "updatedAt",
          label: "审核时间",
          sortable: "custom",
          showOverflowTooltip: true,
          minWidth: 160,
          align: "center",
          formatter: (row, column, cellValue) => {
            return this.$util.toDateString(cellValue);
          },
        },
        {
          columnKey: "action",
          label: "操作",
          width: 150,
          align: "center",
          resizable: false,
          slot: "action",
          fixed: "right",
        },
      ],
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
