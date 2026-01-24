<template>
  <div class="ele-projects-card">
    <el-card shadow="never">
      <!-- 搜索表单 -->
      <el-form :model="where" label-width="77px" class="ele-form-search" @keyup.enter.native="reload"
        @submit.native.prevent>
        <el-row :gutter="15">
          <template>
            <el-col :lg="4" :md="12">
              <el-form-item label="游戏名/ID:">
                <el-input v-model="where.keyword"></el-input>
              </el-form-item>
            </el-col>
          </template>
          <template>
            <el-col :lg="4" :md="12">
              <el-form-item label="CDK:">
                <el-input v-model="where.cdk"></el-input>
              </el-form-item>
            </el-col>
          </template>
          <template>
            <el-col :lg="4" :md="12">
              <el-form-item label="SteamId:">
                <el-input v-model="where.steamId"></el-input>
              </el-form-item>
            </el-col>
          </template>
          <el-col :lg="4" :md="12">
            <el-form-item label="状态:">
              <el-select clearable v-model="where.status" placeholder="全部" class="ele-fluid">
                <el-option label="待使用" value="0">
                  <span style="color: #67c23a">待使用</span>
                </el-option>
                <el-option label="已使用" value="1">
                  <span style="color: #e6a23c">已使用</span>
                </el-option>
                <el-option label="已停用" value="2">
                  <span style="color: #f56c6c">已停用</span>
                </el-option>
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :lg="6" :md="12">
            <el-form-item label="生成日期:">
              <el-date-picker v-model="where.dateRange" type="daterange" range-separator="至" start-placeholder="开始日期"
                end-placeholder="结束日期" class="ele-fluid">
              </el-date-picker>
            </el-form-item>
          </el-col>
          <el-col :lg="6" :md="8">
            <div class="ele-form-actions">
              <el-button type="primary" icon="el-icon-search" class="ele-btn-icon" @click="reload">查询
              </el-button>
              <el-button @click="reset">重置</el-button>
            </div>
          </el-col>
        </el-row>
      </el-form>
      <!-- 数据表格 -->
      <ele-pro-table ref="table" :where="where" :datasource="url" :columns="columns" :selection.sync="selection"
        height="calc(100vh - 405px)">
        <template slot="toolbar">
          <el-button size="small" type="primary" icon="el-icon-plus" class="ele-btn-icon" @click="handleGenerate"
            :disabled="!permission.includes('sys:cdk:generate')">生成CDK
          </el-button>
        </template>
        <!-- 表头工具栏 -->
        <template slot="toolbar">
          <!--          <el-button-->
          <!--            size="small"-->
          <!--            type="primary"-->
          <!--            icon="el-icon-plus"-->
          <!--            class="ele-btn-icon"-->
          <!--            @click="rowEdit(null)">新增-->
          <!--          </el-button>-->
        </template>
        <!-- 操作列 -->
        <template slot="action" slot-scope="{ row }">
          <el-link :underline="false" type="primary" icon="el-icon-delete" @click="handleUnlink(row)"
            :disabled="!permission.includes('sys:cdk:unlink')">解绑
          </el-link>
          <el-link :underline="false" type="danger" icon="el-icon-delete" @click="handleDelete(row)"
            :disabled="!permission.includes('sys:cdk:delete')">删除
          </el-link>
        </template>
        <!-- 地区列 -->
        <template slot="city" slot-scope="{ row }">
          {{
            (row.province ? row.province : "") +
            (row.city ? row.city : "") +
            (row.district ? row.district : "")
          }}
        </template>
        <!-- 经济情况列 -->
        <template slot="economic" slot-scope="{ row }">
          <el-tag v-if="row.economicCondition" size="mini">{{ row.economicCondition }}
          </el-tag>
          <el-tag v-if="row.builtHouse" size="mini">{{ row.builtHouse }}
          </el-tag>
          <el-tag v-if="row.commercialHouse" size="mini">{{ row.commercialHouse }}
          </el-tag>
        </template>
        <!-- 筹款周期列 -->
        <template slot="rangeDate" slot-scope="{ row }">
          {{ row.startDate }} 至 {{ row.endDate }}
        </template>
        <!-- 状态列 -->
        <template slot="status" slot-scope="{}">
          <el-tag>使用中 </el-tag>
        </template>
        <template slot="cdk" slot-scope="{ row }">
          <el-link type="success" @click="handleCopy(row.cdk)">{{
            row.cdk
            }}</el-link>
        </template>
      </ele-pro-table>
    </el-card>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import regions from "ele-admin/packages/regions";
import * as $util from "ele-admin/packages/util.js";
import { MessageBox, Message } from "element-ui";

const columns = [
  {
    prop: "id",
    label: "ID",
    width: 60,
    align: "center",
    showOverflowTooltip: true,
    fixed: "left",
  },
  {
    prop: "cdk",
    label: "CDK",
    sortable: "custom",
    showOverflowTooltip: true,
    minWidth: 160,
    align: "center",
    slot: "cdk",
  },
  {
    prop: "gameId",
    label: "游戏ID",
    showOverflowTooltip: true,
    minWidth: 150,
    align: "center",
  },
  {
    prop: "gameName",
    label: "游戏名称",
    showOverflowTooltip: true,
    minWidth: 200,
    align: "center",
  },
  {
    prop: "steamUserId",
    label: "Steam关联ID",
    showOverflowTooltip: true,
    minWidth: 200,
    align: "center",
  },
  {
    prop: "updateBy",
    label: "状态",
    align: "center",
    width: 150,
    resizable: false,
    slot: "status",
  },
  {
    prop: "createTime",
    label: "创建时间",
    sortable: "custom",
    showOverflowTooltip: true,
    minWidth: 160,
    align: "center",
    formatter: (row, column, cellValue) => {
      const date = new Date(cellValue);
      return $util.toDateString(date);
    },
  },
  {
    prop: "updateTime",
    label: "更新时间",
    sortable: "custom",
    showOverflowTooltip: true,
    minWidth: 160,
    align: "center",
    formatter: (row, column, cellValue) => {
      const date = new Date(cellValue);
      return $util.toDateString(date);
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
];

export default {
  name: "CfProjectsCard",
  props: {},
  computed: {
    ...mapGetters(["permission"]),
  },
  data() {
    return {
      // 省市区数据
      regions: regions,
      // 表格数据接口
      url: "/cdk/list",
      // 表格列配置
      columns: columns,
      // 表格搜索条件
      where: {},
      // 表格选中数据
      selection: [],
      // 当前编辑数据
      current: null,
    };
  },
  mounted() { },
  methods: {
    /* 刷新表格 */
    reload() {
      this.showEdit = false;
      this.$refs.table.reload();
    },
    /* 重置搜索 */
    reset() {
      this.where = {};
      this.reload();
    },
    handleGenerate() {
      this.rowEdit(null, "edit");
    },
    // onProjectTypeChange() {
    //   this.reload();
    // },
    /* 显示编辑 */
    rowEdit(row, type) {
      this.$emit("rowEdit", { row, type });
    },
    handleCopy(item) {
      if (!item) return this.$message.warning("没有内容可复制");
      navigator.clipboard
        .writeText(item)
        .then(() => {
          this.$message.success("复制成功");
        })
        .catch(() => {
          this.$message.error("复制失败");
        });
    },
    handleUnlink(item) {
      console.log(item);
      MessageBox.confirm(`确认要解除绑定吗？`, "提示", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      })
        .then(() => {
          // 用户点击“确定”后的删除逻辑
          this.unlink(item);
          Message.success("解绑成功");
        })
        .catch(() => {
          // 用户点击“取消”
          Message.info("已取消解绑");
        });
    },
    handleDelete(item) {
      console.log(item);
      MessageBox.confirm(`确认要删除吗？`, "提示", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      })
        .then(() => {
          // 用户点击“确定”后的删除逻辑
          this.remove(item);
          Message.success("删除成功");
        })
        .catch(() => {
          // 用户点击“取消”
          Message.info("已取消删除");
        });
    },
    /*解除绑定*/
    unlink(row) {
      const loading = this.$loading({ lock: true });
      this.$http
        .post("/cdk/unlink", [row.id])
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
    /* 删除 */
    remove(row) {
      const loading = this.$loading({ lock: true });
      this.$http
        .post("/cfProjects/delete", [row.id])
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
      this.$confirm("确定要删除选中的项目吗?", "提示", {
        type: "warning",
      })
        .then(() => {
          const loading = this.$loading({ lock: true });
          this.$http
            .post(
              "/cfProjects/delete",
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
        .catch(() => { });
    },
    /* 更改状态 */
    editStatus(row) {
      const loading = this.$loading({ lock: true });
      let params = Object.assign({
        id: row.id,
        status: row.status,
      });
      this.$http
        .post("/cfProjects/status", params)
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

<style scoped>
.ele-form-search>>>.ele-fluid .el-range-input {
  width: 100%;
}
</style>
