<template>
  <div class="ele-projects-card">
    <el-card shadow="never">
      <!-- 搜索表单 -->
      <el-form :model="where" label-width="85px" class="ele-form-search" @keyup.enter.native="reload"
        @submit.native.prevent>
        <el-row :gutter="12">
          <el-col :xs="24" :sm="12" :md="8" :lg="6" :xl="4">
            <el-form-item label="游戏名/ID:" class="compact-form-item">
              <el-input v-model="where.keyword" placeholder="请输入" clearable size="small"></el-input>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12" :md="8" :lg="6" :xl="4">
            <el-form-item label="CDK:" class="compact-form-item">
              <el-input v-model="where.cdk" placeholder="请输入" clearable size="small"></el-input>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12" :md="8" :lg="6" :xl="4">
            <el-form-item label="SteamId:" class="compact-form-item">
              <el-input v-model="where.steamId" placeholder="请输入" clearable size="small"></el-input>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12" :md="8" :lg="6" :xl="4">
            <el-form-item label="状态:" class="compact-form-item">
              <el-select v-model="where.status" placeholder="全部" clearable size="small" class="ele-fluid">
                <el-option label="可用" value="0">
                  <span style="color: #67c23a">可用</span>
                </el-option>
                <el-option label="激活" value="1">
                  <span style="color: #e6a23c">激活</span>
                </el-option>
                <el-option label="禁用" value="2">
                  <span style="color: #f56c6c">禁用</span>
                </el-option>
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12" :md="16" :lg="12" :xl="8">
            <el-form-item label="生成日期:" class="compact-form-item">
              <el-date-picker v-model="where.dateRange" type="daterange" range-separator="至" start-placeholder="开始日期"
                end-placeholder="结束日期" size="small" class="ele-fluid" value-format="yyyy-MM-dd">
              </el-date-picker>
            </el-form-item>
          </el-col>
          <el-col :xs="24" :sm="12" :md="8" :lg="8" :xl="3">
            <div class="ele-form-actions compact-actions">
              <el-button class="search-btn" icon="el-icon-search" @click="reload">查询</el-button>
              <el-button type="warning" class="reset-btn" @click="reset">重置</el-button>
            </div>
          </el-col>
        </el-row>
      </el-form>
      <!-- 数据表格 -->
      <!-- 表格部分保持不变 -->
      <ele-pro-table ref="table" :where="where" :datasource="url" :columns="columns" :selection.sync="selection">
        <template slot="toolbar">
          <div class="toolbar">
            <div class="toolbar-left">
              <el-button type="primary" icon="el-icon-plus" @click="handleGenerate(null)"
                :disabled="!permission.includes('sys:cdk:generate')" class="add-btn">
                生成CDK
              </el-button>
              <el-button type="danger" icon="el-icon-delete" @click="removeBatch"
                :disabled="selection.length === 0 || !permission.includes('sys:user:dall')" class="delete-btn">
                批量删除
              </el-button>
              <el-button type="success" icon="el-icon-upload2" class="export-btn">
                导出数据
              </el-button>
              <el-button type="info" icon="el-icon-download" class="import-btn">
                导入数据
              </el-button>
            </div>
          </div>
        </template>
        <template slot="action" slot-scope="{ row }">
          <el-tooltip content="解绑激活码" placement="top">
            <el-popconfirm class="ele-action" title="确定要解绑激活？" @confirm="unlink(row)"
              :disabled="!permission.includes('sys:cdk:unlink')">
              <el-link :underline="false" slot="reference" type="primary" icon="el-icon-key"
                :disabled="!permission.includes('sys:cdk:unlink')">解绑
              </el-link>
            </el-popconfirm>
          </el-tooltip>
          <el-tooltip content="删除" placement="top">
            <el-popconfirm class="ele-action" title="确定要删除激活码吗？" @confirm="remove(row)"
              :disabled="row.id === 1 || !permission.includes('sys:cdk:delete')">
              <el-link :underline="false" type="danger" icon="el-icon-delete" slot="reference"
                :disabled="!permission.includes('sys:cdk:delete')">删除 </el-link>
            </el-popconfirm>
          </el-tooltip>
        </template>
        <!-- 状态列 -->
        <template slot="status" slot-scope="{row}">
          <el-tag size="mini" :type="row.status === 0 ? 'success' : row.status === 1 ? 'warning' : 'danger'"
            effect="dark">
            {{ row.status === 0 ? '可用' : row.status === 1 ? '激活' : '禁用' }}
          </el-tag>
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
// script部分保持不变
import { mapGetters } from "vuex";
import * as $util from "ele-admin/packages/util.js";
import { Message } from "element-ui";

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
    minWidth: 180,
    align: "center",
    slot: "cdk",
  },
  {
    prop: "gameId",
    label: "游戏ID",
    showOverflowTooltip: true,
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
    label: "关联SteamID",
    showOverflowTooltip: true,
    minWidth: 100,
    align: "center",
  },
  {
    prop: "description",
    label: "备注信息",
    showOverflowTooltip: true,
    minWidth: 200,
    align: "center",
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
      // 表格数据接口
      url: "/cdk/list",
      // 表格列配置
      columns: columns,
      // 表格搜索��件
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
    /*解除绑定*/
    unlink(row) {
      const loading = this.$loading({ lock: true });
      this.$http
        .post("/cdk/unlink/" + row.id)
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
        .post("/cdk/delete/" + row.id)
        .then((res) => {
          loading.close();
          if (res.data.code === 200) {
            Message.info("删除成功");
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
        this.$message.error("���至少选择一条数据");
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
/* 原有的样式保持不变 */
.ele-form-search>>>.ele-fluid .el-range-input {
  width: 100%;
}

.add-btn {
  background: linear-gradient(135deg, #a66cff 0%, #6f42c1 100%);
  border: none;
  color: #fff;
  transition: background 0.2s ease, transform 0.1s ease, box-shadow 0.2s ease;
}

/* hover：更亮一点 */
.add-btn:hover {
  background: linear-gradient(135deg, #b58cff 0%, #7b55d4 100%);
  box-shadow: 0 6px 16px rgba(111, 66, 193, 0.35);
}

.add-btn:active {
  background: linear-gradient(135deg, #8f5be0 0%, #5a2fa6 100%);
  transform: translateY(1px);
  box-shadow: 0 3px 8px rgba(111, 66, 193, 0.35);
}

.search-btn {
  background: linear-gradient(135deg, #5b8cff 0%, #3a5bdc 100%);
  border: none;
  color: #fff;
  transition: background 0.2s ease, transform 0.1s ease, box-shadow 0.2s ease;
}

/* hover：更清亮 */
.search-btn:hover {
  background: linear-gradient(135deg, #6fa0ff 0%, #4c6eea 100%);
  box-shadow: 0 6px 16px rgba(58, 91, 220, 0.35);
}

/* active */
.search-btn:active {
  background: linear-gradient(135deg, #4a78e0 0%, #2f4bb8 100%);
  transform: translateY(1px);
  box-shadow: 0 3px 8px rgba(58, 91, 220, 0.35);
}

.reset-btn {
  background: linear-gradient(135deg, #9aa0b5 0%, #7d8296 100%);
  border: none;
  color: #fff;
  transition: background 0.2s ease, transform 0.1s ease, box-shadow 0.2s ease;
}

/* hover：稍微提亮 */
.reset-btn:hover {
  background: linear-gradient(135deg, #a9afc4 0%, #8c91a6 100%);
  box-shadow: 0 6px 16px rgba(125, 130, 150, 0.3);
}

/* active */
.reset-btn:active {
  background: linear-gradient(135deg, #858aa0 0%, #686d82 100%);
  transform: translateY(1px);
  box-shadow: 0 3px 8px rgba(125, 130, 150, 0.3);
}

/* 新增的样式 */
.ele-form-search {
  padding: 16px 16px 8px;
  background: #f8f9fa;
  border-radius: 4px;
  margin-bottom: 16px;
}

.compact-form-item {
  margin-bottom: 8px;
}

.compact-form-item :deep(.el-form-item__label) {
  line-height: 32px;
  padding-right: 8px;
}

.compact-form-item :deep(.el-form-item__content) {
  line-height: 32px;
}

.compact-actions {
  display: flex;
  align-items: center;
  height: 32px;
  margin-top: 4px;
}

.compact-actions .el-button {
  flex: 1;
  margin-right: 8px;
}

.compact-actions .el-button:last-child {
  margin-right: 0;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .ele-form-search {
    padding: 12px;
  }

  .compact-actions {
    margin-top: 8px;
  }
}

@media (max-width: 576px) {
  .ele-form-search {
    padding: 8px;
  }

  .compact-form-item {
    margin-bottom: 12px;
  }

  .compact-actions {
    flex-wrap: wrap;
    gap: 8px;
  }

  .compact-actions .el-button {
    flex: 0 0 calc(50% - 4px);
    margin-right: 0;
  }
}
</style>
