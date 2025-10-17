<template>
  <div class="ele-body">
    <el-card shadow="never">
      <!-- 搜索表单 -->
      <el-form
        :model="where"
        label-width="77px"
        class="ele-form-search"
        @keyup.enter.native="reload"
        @submit.native.prevent
      >
        <el-row :gutter="15">
          <el-col :lg="6" :md="12">
            <el-form-item label="基金名称:">
              <el-input
                clearable
                v-model="where.name"
                placeholder="请输入基金名称"
              />
            </el-form-item>
          </el-col>
          <el-col :lg="6" :md="12">
            <div class="ele-form-actions">
              <el-button
                type="primary"
                icon="el-icon-search"
                class="ele-btn-icon"
                @click="reload"
                >查询
              </el-button>
              <el-button @click="reset">重置</el-button>
              <el-button
                type="success"
                v-role="['ROLE_SUPER']"
                @click="openEdit(null)"
                >添加基金</el-button
              >
            </div>
          </el-col>
        </el-row>
      </el-form>
      <!-- 数据表格 -->
      <ele-pro-table
        ref="table"
        :where="where"
        :datasource="url"
        :columns="columns"
        :selection.sync="selection"
        height="calc(100vh - 315px)"
      >
        <!-- 表头工具栏 -->
        <template slot="toolbar"> </template>
        <template slot="creatorUserName" slot-scope="{ row }">
          <el-tag>{{ row["creatorUserName"] }}</el-tag>
        </template>
        <!-- 操作列 -->
        <template slot="action" slot-scope="{ row }">
          <el-link
            v-role="['ROLE_SUPER']"
            icon="el-icon-view"
            :underline="false"
            @click="openEdit(row, 'detail')"
            >查看详情
          </el-link>
          <el-popconfirm
            v-role="['ROLE_SUPER']"
            class="ele-action"
            title="确定要删除此认证记录吗？"
            @confirm="remove(row)"
          >
            <el-link
              type="danger"
              slot="reference"
              :underline="false"
              icon="el-icon-delete"
              >删除
            </el-link>
          </el-popconfirm>
        </template>
      </ele-pro-table>
    </el-card>
    <!-- 编辑弹窗 -->
    <FundEdit
      v-if="showEdit"
      @close="showEdit = false"
      :data="current"
      :visible="showEdit"
      @done="reload"
    />
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import * as $util from "ele-admin/packages/util";
import FundEdit from "./record-edit.vue";
export default {
  name: "cfFundList",
  components: { FundEdit },
  computed: {
    ...mapGetters(["permission", "userId"]),
  },
  data() {
    return {
      // 表格数据接口
      url: "/fundList/list",
      // 表格列配置
      columns: [
        {
          prop: "id",
          label: "ID",
          width: 60,
          align: "center",
          showOverflowTooltip: true,
          fixed: "left",
        },
        {
          prop: "name",
          label: "基金名称",
          showOverflowTooltip: true,
          minWidth: 200,
          align: "center",
        },
        {
          prop: "code",
          label: "邀请码",
          showOverflowTooltip: true,
          minWidth: 200,
          align: "center",
        },
        {
          prop: "description",
          label: "描述",
          showOverflowTooltip: true,
          minWidth: 200,
          align: "center",
        },
        // {
        //   prop: "creatorUserName",
        //   label: "创建用户",
        //   showOverflowTooltip: true,
        //   minWidth: 200,
        //   align: "center",
        //   slot: 'creatorUserName',
        // },
        {
          prop: "createdAt",
          label: "申请时间",
          sortable: "custom",
          showOverflowTooltip: true,
          minWidth: 160,
          align: "center",
          formatter: (row, column, cellValue) => {
            return $util.toDateString(cellValue);
          },
        },
        {
          columnKey: "action",
          label: "操作",
          width: 215,
          align: "center",
          resizable: false,
          slot: "action",
          fixed: "right",
        },
      ],
      // 表格搜索条件
      where: {},
      // 表格选中数据
      selection: [],
      // 当前编辑数据
      current: null,
      // 是否显示编辑弹窗
      showEdit: false,
      // 栏目列表
      cateList: [],
    };
  },
  methods: {
    /* 刷新表格 */
    reload() {
      this.showEdit = false;
      this.$refs.table.reload();
      this.$store.dispatch("fund/getFundList", this.userId);
      // this.$refs.table.reload({where: this.where});
    },
    /* 重置搜索 */
    reset() {
      this.where = {};
      this.reload();
    },
    /* 显示编辑 */
    openEdit(row) {
      this.current = row == null ? { id: null } : row;
      this.showEdit = true;
    },
    /* 删除 */
    remove(row) {
      const loading = this.$loading({ lock: true });
      this.$http
        .post("/fundList/delete", [row.id])
        .then((res) => {
          loading.close();
          if (res.data.code === 200) {
            this.$message.success(res.data.message);
            this.reload();
          } else {
            this.$message.error(res.data.message);
          }
        })
        .catch((e) => {
          loading.close();
          this.$message.error(e.message);
        });
    },
    /* 批量删除 */
    removeBatch() {
      if (!this.selection.length) {
        this.$message.error("请至少选择一条数据");
        return;
      }
      this.$confirm("确定要删除选中的文章吗?", "提示", {
        type: "warning",
      })
        .then(() => {
          const loading = this.$loading({ lock: true });
          this.$http
            .post(
              "/cfProjectsCertification/delete",
              this.selection.map((d) => d.id)
            )
            .then((res) => {
              loading.close();
              if (res.data.code === 200) {
                this.$message.success(res.data.message);
                this.reload();
              } else {
                this.$message.error(res.data.message);
              }
            })
            .catch((e) => {
              loading.close();
              this.$message.error(e.message);
            });
        })
        .catch(() => {});
    },
    /* 更改状态 */
    editStatus(row) {
      const loading = this.$loading({ lock: true });
      let params = Object.assign({
        id: row.id,
        status: row.status,
      });
      this.$http
        .post("/cfProjectsCertification/status", params)
        .then((res) => {
          loading.close();
          if (res.data.code === 200) {
            this.$message.success(res.data.message);
          } else {
            row.status = !row.status ? 1 : 2;
            this.$message.error(res.data.message);
          }
        })
        .catch((e) => {
          loading.close();
          this.$message.error(e.message);
        });
    },
  },
};
</script>

<style scoped></style>
