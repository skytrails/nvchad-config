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
            <el-form-item label="活动标题:">
              <el-input
                clearable
                v-model="where.title"
                placeholder="请输入活动标题"
              />
            </el-form-item>
          </el-col>
          <el-col :lg="6" :md="12">
            <el-form-item label="状态:">
              <el-select
                clearable
                v-model="where.status"
                placeholder="全部"
                class="ele-fluid"
              >
                <el-option label="生效中" value="1" />
                <el-option label="已停止" value="2" />
              </el-select>
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
        <template slot="toolbar">
          <el-button
            size="small"
            type="primary"
            icon="el-icon-plus"
            class="ele-btn-icon"
            @click="openEdit(null)"
            >新增
          </el-button>
        </template>

        <template v-slot:fundId="{ row }">
          <el-tag type="success">{{ row['fundId'] | fundNameById(fundList)}}</el-tag>
        </template>
        <!-- 操作列 -->
        <template slot="action" slot-scope="{ row }">
          <el-link
            type="primary"
            :underline="false"
            icon="el-icon-edit"
            @click="openEdit(row)"
            >修改
          </el-link>
          <el-popconfirm
            class="ele-action"
            title="确定要删除此活动吗？"
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
        <!-- 文章封面列 -->
        <template slot="imageUrl" slot-scope="{ row }">
          <el-avatar shape="square" :size="60" :src="row.imageUrl" />
        </template>
        <!-- 状态列 -->
        <template slot="status" slot-scope="{ row }">
          <el-tag v-if="row.status === 1" size="mini">生效中 </el-tag>
          <el-tag v-if="row.status === 2" type="info" size="mini"
            >已停止
          </el-tag>
          <!--          <el-switch-->
          <!--            v-model="row.status"-->
          <!--            @change="editStatus(row)"-->
          <!--            :active-value="1"-->
          <!--            :inactive-value="2"/>-->
        </template>
      </ele-pro-table>
    </el-card>
    <!-- 编辑弹窗 -->
    <events-edit
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
import EventsEdit from "./events-edit";
export default {
  name: "CfEvents",
  components: { EventsEdit },
  computed: {
    ...mapGetters(["permission", "fundList"]),
  },
  data() {
    return {
      // 表格数据接口
      url: "/cfEvents/index",
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
          columnKey: "imageUrl",
          label: "活动封面",
          align: "center",
          showOverflowTooltip: true,
          minWidth: 100,
          slot: "imageUrl",
        },
        {
          prop: "title",
          label: "活动标题",
          showOverflowTooltip: true,
          minWidth: 250,
          align: "center",
        },
        {
          prop: "profile",
          label: "活动简介",
          showOverflowTooltip: true,
          minWidth: 250,
          align: "center",
        },
        {
          prop: "fundId",
          label: "关联基金",
          minWidth: 150,
          align: "center",
          slot: "fundId",
        },
        {
          prop: "startAt",
          label: "开始时间",
          sortable: "custom",
          showOverflowTooltip: true,
          minWidth: 160,
          align: "center",
          formatter: (row, column, cellValue) => {
            return this.$util.toDateString(cellValue, "yyyy-MM-dd");
          },
        },
        {
          prop: "endAt",
          label: "截止时间",
          sortable: "custom",
          showOverflowTooltip: true,
          minWidth: 160,
          align: "center",
          formatter: (row, column, cellValue) => {
            return this.$util.toDateString(cellValue, "yyyy-MM-dd");
          },
        },
        {
          prop: "status",
          label: "状态",
          align: "center",
          width: 150,
          resizable: false,
          slot: "status",
        },
        // {
        //   prop: 'sort',
        //   label: '排序号',
        //   align: 'center',
        //   showOverflowTooltip: true,
        //   width: 100
        // },
        {
          prop: "createdAt",
          label: "创建时间",
          sortable: "custom",
          showOverflowTooltip: true,
          minWidth: 160,
          align: "center",
          formatter: (row, column, cellValue) => {
            return this.$util.toDateString(cellValue);
          },
        },
        {
          prop: "updatedAt",
          label: "更新时间",
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
  filters: {
    fundNameById(id, fundList) {
      // 显式传入fundList
      const fund = fundList.find((item) => item.id == id);
      return fund ? fund.name : "";
    },
  },
  methods: {
    /* 刷新表格 */
    reload() {
      this.showEdit = false;
      this.$refs.table.reload();
      // this.$refs.table.reload({where: this.where});
    },
    /* 重置搜索 */
    reset() {
      this.where = {};
      this.reload();
    },
    /* 显示编辑 */
    openEdit(row) {
      this.current = row == null ? { status: 1 } : row;
      this.showEdit = true;
    },
    /* 删除 */
    remove(row) {
      const loading = this.$loading({ lock: true });
      this.$http
        .post("/cfEvents/delete", [row.id])
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
              "/cfEvents/delete",
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
        .post("/cfEvents/status", params)
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
