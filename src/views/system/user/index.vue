<template>
  <div class="user-management">
    <!-- 主要卡片 -->
    <el-card shadow="never" class="main-card">
      <!-- 搜索栏 -->
      <div class="search-bar">
        <el-form :model="where" label-width="auto" class="search-form">
          <el-row :gutter="20" class="align-bottom">
            <el-col :xs="24" :sm="12" :md="8" :lg="6">
              <div class="form-group">
                <label class="form-label">
                  <i class="el-icon-user"></i>
                  用户账号
                </label>
                <el-input v-model="where.username" placeholder="输入用户账号" clearable prefix-icon="el-icon-search"
                  class="search-input" @keyup.enter.native="reload" />
              </div>
            </el-col>
            <el-col :xs="24" :sm="12" :md="8" :lg="6">
              <div class="form-group">
                <label class="form-label">
                  <i class="el-icon-male"></i>
                  性别
                </label>
                <el-select v-model="where.gender" placeholder="选择性别" clearable class="search-input">
                  <el-option label="男" value="1" />
                  <el-option label="女" value="2" />
                  <el-option label="保密" value="3" />
                </el-select>
              </div>
            </el-col>
            <el-col :xs="24" :sm="12" :md="8" :lg="6">
              <div class="form-group">
                <label class="form-label">
                  <i class="el-icon-s-flag"></i>
                  状态
                </label>
                <el-select v-model="where.status" placeholder="选择状态" clearable class="search-input">
                  <el-option label="启用" value="1" />
                  <el-option label="禁用" value="2" />
                </el-select>
              </div>
            </el-col>
            <el-col :xs="24" :sm="24" :md="24" :lg="6">
              <div class="form-actions">
                <el-button icon="el-icon-search" @click="reload" class="search-btn">
                  查询
                </el-button>
                <el-button icon="el-icon-refresh-right" @click="reset" class="reset-btn">
                  重置
                </el-button>
                <el-button type="text" icon="el-icon-s-operation" @click="toggleAdvanced">
                  {{ showAdvanced ? '简化' : '高级' }}
                </el-button>
              </div>
            </el-col>
          </el-row>

          <!-- 高级搜索 -->
          <el-collapse-transition>
            <div v-show="showAdvanced" class="advanced-search">
              <el-divider><span class="advanced-title">高级筛选</span></el-divider>
              <el-row :gutter="20">
                <el-col :xs="24" :sm="12" :md="8">
                  <div class="form-group">
                    <label class="form-label">
                      <i class="el-icon-phone-outline"></i>
                      手机号
                    </label>
                    <el-input v-model="where.mobile" placeholder="输入手机号" clearable class="search-input" />
                  </div>
                </el-col>
                <el-col :xs="24" :sm="12" :md="8">
                  <div class="form-group">
                    <label class="form-label">
                      <i class="el-icon-message"></i>
                      邮箱
                    </label>
                    <el-input v-model="where.email" placeholder="输入邮箱" clearable class="search-input" />
                  </div>
                </el-col>
                <el-col :xs="24" :sm="12" :md="8">
                  <div class="form-group">
                    <label class="form-label">
                      <i class="el-icon-date"></i>
                      创建时间
                    </label>
                    <el-date-picker v-model="dateRange" type="daterange" range-separator="至" start-placeholder="开始日期"
                      end-placeholder="结束日期" value-format="yyyy-MM-dd" class="search-input" />
                  </div>
                </el-col>
              </el-row>
            </div>
          </el-collapse-transition>
        </el-form>
      </div>

      <!-- 工具栏 -->
      <div class="toolbar">
        <div class="toolbar-left">
          <el-button type="primary" icon="el-icon-plus" @click="openEdit(null)"
            :disabled="!permission.includes('sys:user:add')" class="add-btn">
            添加用户
          </el-button>
          <el-button type="danger" icon="el-icon-delete" @click="removeBatch"
            :disabled="selection.length === 0 || !permission.includes('sys:user:dall')" class="delete-btn">
            批量删除
          </el-button>
          <el-button type="success" icon="el-icon-upload2" @click="exportData" class="export-btn">
            导出数据
          </el-button>
          <el-button type="info" icon="el-icon-download" @click="importData" class="import-btn">
            导入用户
          </el-button>
        </div>
        <div class="toolbar-right">
          <el-button icon="el-icon-refresh" circle @click="reload" class="refresh-btn" />
          <el-dropdown @command="handleColumnCommand">
            <el-button icon="el-icon-s-grid" circle />
            <el-dropdown-menu slot="dropdown">
              <el-dropdown-item command="customize">
                <i class="el-icon-setting"></i>自定义列
              </el-dropdown-item>
              <el-dropdown-item command="density" divided>
                <i class="el-icon-s-data"></i>表格密度
              </el-dropdown-item>
              <el-dropdown-item command="fullscreen">
                <i class="el-icon-full-screen"></i>全屏显示
              </el-dropdown-item>
            </el-dropdown-menu>
          </el-dropdown>
        </div>
      </div>

      <!-- 数据表格 -->
      <ele-pro-table ref="table" :where="where" :datasource="url" :columns="columns" :selection.sync="selection"
        class="data-table" @selection-change="handleSelectionChange">
        <!-- 用户头像 -->
        <template slot="avatar" slot-scope="{ row }">
          <div class="avatar-cell">
            <circle-avatar :text="row.username || row.realname" :size="48" />
            <div class="avatar-info">
              <div class="user-name">
                <router-link :to="'/system/user/info?id=' + row.id" class="user-link">
                  {{ row.realname || row.username }}
                </router-link>
              </div>
              <div class="user-id">ID: {{ row.id }}</div>
            </div>
          </div>
        </template>

        <!-- 用户账号 -->
        <template slot="username" slot-scope="{ row }">
          <div class="account-cell">
            <div class="account-name">{{ row.username }}</div>
            <div class="account-type">
              <el-tag v-if="row.type === 1" size="mini" type="warning">
                管理员
              </el-tag>
              <el-tag v-else size="mini" type="info">
                普通用户
              </el-tag>
            </div>
          </div>
        </template>

        <!-- 性别 -->
        <template slot="gender" slot-scope="{ row }">
          <div class="gender-cell">
            <el-tag :type="['success', 'primary', 'warning'][row.gender - 1]" size="small" effect="plain">
              <i :class="[
                'el-icon-male',
                'el-icon-female',
                'el-icon-question'
              ][row.gender - 1]"></i>
              {{ ["男", "女", "保密"][row.gender - 1] }}
            </el-tag>
          </div>
        </template>

        <!-- 联系方式 -->
        <template slot="contact" slot-scope="{ row }">
          <div class="contact-cell">
            <div class="contact-item">
              <i class="el-icon-phone-outline"></i>
              <span>{{ row.mobile || '未设置' }}</span>
            </div>
            <div class="contact-item">
              <i class="el-icon-message"></i>
              <span>{{ row.email || '未设置' }}</span>
            </div>
          </div>
        </template>

        <!-- 角色 -->
        <template slot="roles" slot-scope="{ row }">
          <div class="roles-cell">
            <el-tag v-for="item in row.roles" :key="item.id" size="small" type="primary" effect="light"
              class="role-tag">
              {{ item.name }}
            </el-tag>
            <el-tag v-if="!row.roles || row.roles.length === 0" size="small" type="info" effect="plain">
              未分配角色
            </el-tag>
          </div>
        </template>

        <!-- 状态 -->
        <template slot="status" slot-scope="{ row }">
          <div class="status-cell">
            <el-tooltip :content="row.status === 1 ? '点击禁用' : '点击启用'" placement="top" v-if="row.id !== 1">
              <el-switch v-model="row.status" :active-value="1" :inactive-value="2" @change="editStatus(row)"
                active-color="#13ce66" inactive-color="#ff3849" />
            </el-tooltip>
            <div v-if="row.id === 1" class="super-admin">
              <el-tag type="danger" size="small" effect="dark">
                <i class="el-icon-star-on"></i>
                超级管理员
              </el-tag>
            </div>
          </div>
        </template>

        <!-- 操作 -->
        <template slot="action" slot-scope="{ row }">
          <div class="action-buttons">
            <el-tooltip content="编辑" placement="top">
              <el-button type="primary" icon="el-icon-edit" size="small" circle @click="openEdit(row)"
                :disabled="row.id === 1 || !permission.includes('sys:user:edit')" class="action-btn edit-btn" />
            </el-tooltip>

            <el-tooltip content="重置密码" placement="top">
              <el-popconfirm title="确定要重置密码吗？" @confirm="resetPwd(row)"
                :disabled="row.id === 1 || !permission.includes('sys:user:resetPwd')">
                <el-button slot="reference" type="warning" icon="el-icon-key" size="small" circle
                  :disabled="row.id === 1 || !permission.includes('sys:user:resetPwd')" class="action-btn " />
              </el-popconfirm>
            </el-tooltip>

            <el-tooltip content="删除" placement="top">
              <el-popconfirm title="确定要删除此用户吗？" @confirm="remove(row)"
                :disabled="row.id === 1 || !permission.includes('sys:user:delete')">
                <el-button slot="reference" type="danger" icon="el-icon-delete" size="small" circle
                  :disabled="row.id === 1 || !permission.includes('sys:user:delete')" class="action-btn delete-btn" />
              </el-popconfirm>
            </el-tooltip>

            <el-tooltip content="查看详情" placement="top">
              <router-link :to="'/system/user/info?id=' + row.id">
                <el-button type="info" icon="el-icon-view" size="small" circle class="action-btn view-btn" />
              </router-link>
            </el-tooltip>
          </div>
        </template>
      </ele-pro-table>
    </el-card>

    <!-- 编辑弹窗 -->
    <user-edit :data="current" :visible.sync="showEdit" @done="reload" />

    <!-- 显示密码 -->
    <password-copy :data="passwordText" :visible.sync="showPassword" />

    <!-- 导入弹窗 -->
    <import-dialog :visible.sync="showImport" @success="reload" />

    <!-- 自定义列弹窗 -->
    <column-customize :columns="columns" :visible.sync="showColumnCustomize" />
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import UserEdit from "./user-edit";
import PasswordCopy from "./password-copy";
import CircleAvatar from "@/components/CircleAvatar.vue";
import ColumnCustomize from "@/components/ColumnCustomize.vue";
import ImportDialog from "@/components/ImportDialog.vue";

export default {
  name: "SystemUser",
  components: {
    UserEdit,
    PasswordCopy,
    ImportDialog,
    ColumnCustomize,
    CircleAvatar
  },

  computed: {
    ...mapGetters(["permission"]),
  },

  data() {
    return {
      // 数据接口
      url: "/admin/list",

      // 统计信息
      totalUsers: 0,
      activeUsers: 0,
      todayNew: 0,

      // 搜索条件
      where: {},
      dateRange: [],
      showAdvanced: false,

      // 表格配置
      columns: [
        {
          columnKey: "selection",
          type: "selection",
          width: 55,
          align: "center",
          fixed: "left"
        },
        {
          prop: "avatar",
          label: "用户信息",
          align: "left",
          minWidth: 200,
          slot: "avatar",
          fixed: "left"
        },
        {
          prop: "username",
          label: "账号信息",
          align: "left",
          minWidth: 150,
          slot: "username"
        },
        {
          prop: "genderName",
          label: "性别",
          align: "center",
          width: 100,
          slot: "gender"
        },
        {
          prop: "contact",
          label: "联系方式",
          align: "left",
          minWidth: 180,
          slot: "contact"
        },
        {
          columnKey: "roles",
          label: "角色",
          align: "left",
          minWidth: 200,
          slot: "roles"
        },
        {
          prop: "intro",
          label: "个人简介",
          align: "left",
          minWidth: 150,
          showOverflowTooltip: true
        },
        {
          prop: "status",
          label: "状态",
          align: "center",
          width: 100,
          slot: "status"
        },
        {
          prop: "createdAt",
          label: "创建时间",
          align: "center",
          width: 180,
          formatter: (row, column, cellValue) => {
            return this.formatDate(cellValue, "YYYY-MM-DD HH:mm:ss");
          }
        },
        {
          prop: "updatedAt",
          label: "更新时间",
          align: "center",
          width: 180,
          formatter: (row, column, cellValue) => {
            return this.formatDate(cellValue, "YYYY-MM-DD HH:mm:ss");
          }
        },
        {
          columnKey: "action",
          label: "操作",
          width: 220,
          align: "center",
          fixed: "right",
          slot: "action"
        }
      ],

      // 表格数据
      selection: [],
      current: null,

      // 弹窗控制
      showEdit: false,
      showPassword: false,
      showImport: false,
      showColumnCustomize: false,

      // 其他数据
      passwordText: "",
    };
  },

  mounted() {
    // this.loadStatistics();
  },

  methods: {
    /* 加载统计信息 */
    loadStatistics() {
      this.$http.get("/admin/statistics").then(res => {
        if (res.data.code === 200) {
          const data = res.data.data;
          this.totalUsers = data.total || 0;
          this.activeUsers = data.active || 0;
          this.todayNew = data.todayNew || 0;
        }
      }).catch(e => {
        console.error('加载统计信息失败:', e);
      });
    },

    /* 刷新表格 */
    reload() {
      this.$refs.table.reload({ where: this.getWhere() });
    },

    /* 获取搜索条件 */
    getWhere() {
      const where = { ...this.where };

      // 处理时间范围
      if (this.dateRange && this.dateRange.length === 2) {
        where.startDate = this.dateRange[0];
        where.endDate = this.dateRange[1];
      }

      return where;
    },

    /* 重置搜索 */
    reset() {
      this.where = {};
      this.dateRange = [];
      this.reload();
    },

    /* 切换高级搜索 */
    toggleAdvanced() {
      this.showAdvanced = !this.showAdvanced;
    },

    /* 打开编辑弹窗 */
    openEdit(row) {
      this.current = row;
      this.showEdit = true;
    },

    /* 删除用户 */
    remove(row) {
      const loading = this.$loading({ lock: true });
      this.$http
        .post("/sysUser/delete", [row.id])
        .then((res) => {
          loading.close();
          if (res.data.code === 200) {
            this.$message.success(res.data.message);
            this.reload();
            this.loadStatistics();
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
        this.$message.warning("请至少选择一条数据");
        return;
      }

      this.$confirm(`确定要删除选中的 ${this.selection.length} 个用户吗？`, "警告", {
        type: "warning",
        confirmButtonText: "确定删除",
        cancelButtonText: "取消",
        confirmButtonClass: "el-button--danger"
      })
        .then(() => {
          const loading = this.$loading({ lock: true });
          this.$http
            .post(
              "/sysUser/delete",
              this.selection.map((d) => d.id)
            )
            .then((res) => {
              loading.close();
              if (res.data.code === 200) {
                this.$message.success(res.data.message);
                this.reload();
                this.loadStatistics();
                this.selection = [];
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

    /* 选择改变 */
    handleSelectionChange(selection) {
      this.selection = selection;
    },

    /* 更改状态 */
    editStatus(row) {
      const newStatus = row.status;
      const statusText = newStatus === 1 ? "启用" : "禁用";

      const loading = this.$loading({ lock: true });
      let params = Object.assign({
        id: row.id,
        status: newStatus,
      });

      this.$http
        .post("/admin/updateStatus", params)
        .then((res) => {
          loading.close();
          if (res.data.code === 200) {
            this.$message.success(`用户已${statusText}`);
            this.reload();
            this.loadStatistics();
          } else {
            // 回滚状态
            row.status = newStatus === 1 ? 2 : 1;
            this.$message.error(res.data.message);
          }
        })
        .catch((e) => {
          loading.close();
          // 回滚状态
          row.status = newStatus === 1 ? 2 : 1;
          this.$message.error(e.message);
        });
    },

    /* 重置密码 */
    resetPwd(row) {
      const loading = this.$loading({ lock: true });
      this.$http
        .post("/admin/resetPassword/" + row.id)
        .then((res) => {
          loading.close();
          if (res.data.code === 200) {
            this.passwordText = res.data.data;
            this.showPassword = true;
          } else {
            this.$message.error(res.data.message);
          }
        })
        .catch((e) => {
          loading.close();
          this.$message.error(e.message);
        });
    },

    /* 导出数据 */
    exportData() {
      this.$message.info("导出功能开发中...");
    },

    /* 导入数据 */
    importData() {
      this.showImport = true;
    },

    /* 处理列命令 */
    handleColumnCommand(command) {
      switch (command) {
        case 'customize':
          this.showColumnCustomize = true;
          break;
        case 'density':
          this.changeTableDensity();
          break;
        case 'fullscreen':
          this.toggleFullscreen();
          break;
      }
    },

    /* 切换表格密度 */
    changeTableDensity() {
      // 切换表格密度逻辑
    },

    /* 切换全屏 */
    toggleFullscreen() {
      // 全屏逻辑
    },

    /* 格式化日期 */
    formatDate(date) {
      if (!date) return '-';
      return this.$util.toDateString(new Date(date));
    }
  }
};
</script>

<style scoped>
.user-management {
  padding: 20px;
}

/* 页面头部 */
.page-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  padding: 24px;
  color: white;
  margin-bottom: 24px;
  position: relative;
  overflow: hidden;
}

.page-header::before {
  content: '';
  position: absolute;
  top: -50%;
  right: -50%;
  width: 200%;
  height: 200%;
  background: radial-gradient(circle, rgba(255, 255, 255, 0.1) 1px, transparent 1px);
  background-size: 20px 20px;
  opacity: 0.1;
}

.header-content {
  margin-bottom: 24px;
}

.page-title {
  font-size: 28px;
  font-weight: 600;
  margin: 0 0 8px 0;
  display: flex;
  align-items: center;
  gap: 12px;
}

.page-subtitle {
  font-size: 14px;
  opacity: 0.9;
  margin: 0;
}

.header-stats {
  display: flex;
  gap: 24px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 16px;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-radius: 12px;
  padding: 16px;
  min-width: 180px;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.stat-icon.total {
  background: rgba(86, 204, 242, 0.2);
  color: #56ccf2;
}

.stat-icon.active {
  background: rgba(82, 196, 26, 0.2);
  color: #52c41a;
}

.stat-icon.today {
  background: rgba(255, 132, 0, 0.2);
  color: #ff8400;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: 700;
  line-height: 1;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  opacity: 0.9;
}

/* 主卡片 */
.main-card {
  border-radius: 12px;
  border: none;
}

/* 搜索栏 */
.search-bar {
  margin-bottom: 20px;
}

.search-form {
  padding: 24px;
  background: #f8f9fa;
  border-radius: 8px;
}

.align-bottom {
  display: flex;
  align-items: flex-end !important;
}

.form-group {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.form-label {
  display: block;
  margin-bottom: 8px;
  font-size: 14px;
  font-weight: 500;
  color: #606266;
  display: flex;
  align-items: center;
  gap: 6px;
}

.search-input {
  width: 100%;
}

.form-actions {
  display: flex;
  align-items: flex-end;
  height: 100%;
  gap: 12px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.search-btn {
  background: linear-gradient(135deg, #1890ff 0%, #36cfc9 100%);
  border: none;
  color: white;
  padding: 10px 24px;
}

.search-btn:hover {
  background: linear-gradient(135deg, #1890ff 0%, #36cfc9 60%);
}

.search-btn:active {
  opacity: 0.8;
}

.advanced-search {
  margin-top: 20px;
}

.advanced-title {
  color: #909399;
  font-size: 14px;
  padding: 0 12px;
}

/* 工具栏 */
.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding: 0 24px;
}

.toolbar-left {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.toolbar-right {
  display: flex;
  gap: 8px;
}

.add-btn {
  background: linear-gradient(135deg, #36c 0%, #6739b6 100%);
  border: none;
}

.delete-btn {
  background: linear-gradient(135deg, #f56c6c 0%, #f2719c 100%);
  border: none;
}

.refresh-btn {
  border: 1px solid #dcdfe6;
}

/* 数据表格 */
.data-table ::v-deep .el-table {
  border-radius: 8px;
  overflow: hidden;
}

/* 头像单元格 */
.avatar-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.avatar-info {
  line-height: 1.4;
}

.user-name {
  font-weight: 500;
  margin-bottom: 4px;
}

.user-link {
  color: #303133;
  text-decoration: none;
  transition: color 0.3s;
}

.user-link:hover {
  color: #1890ff;
}

.user-id {
  font-size: 12px;
  color: #909399;
}

/* 账号单元格 */
.account-cell {
  line-height: 1.4;
}

.account-name {
  font-weight: 500;
  margin-bottom: 4px;
}

.account-type {
  display: inline-block;
}

/* 性别单元格 */
.gender-cell {
  display: flex;
  justify-content: center;
}

/* 联系单元格 */
.contact-cell {
  line-height: 1.6;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 14px;
  color: #606266;
}

.contact-item i {
  color: #909399;
  font-size: 14px;
}

/* 角色单元格 */
.roles-cell {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  min-height: 32px;
  align-items: center;
}

.role-tag {
  cursor: pointer;
  transition: all 0.3s;
}

.role-tag:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(24, 144, 255, 0.2);
}

/* 状态单元格 */
.status-cell {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
}

.super-admin {
  display: flex;
  justify-content: center;
}

/* 操作按钮 */
.action-buttons {
  display: flex;
  gap: 8px;
  justify-content: center;
}

.action-btn {
  transition: all 0.3s;
}

.action-btn:hover {
  transform: scale(1.1);
}

.edit-btn {
  background: linear-gradient(135deg, #1890ff 0%, #40a9ff 100%);
  border: none;
  color: white;
}

.edit-btn:hover {
  background: linear-gradient(135deg, #096dd9 0%, #1890ff 100%);
}

.reset-btn {
  padding: 10px 24px;
  background: linear-gradient(135deg, #faad14 0%, #ffc53d 100%);
  border: none;
  color: white;
}

.reset-btn:hover {
  background: linear-gradient(135deg, #faad14 0%, #ffc53d 60%);
}

.reset-btn:active {
  opacity: 0.8;
}

.delete-btn {
  background: linear-gradient(135deg, #ff4d4f 0%, #ff7875 100%);
  border: none;
  color: white;
}

.delete-btn:hover {
  background: linear-gradient(135deg, #d9363e 0%, #ff4d4f 100%);
}

.view-btn {
  background: linear-gradient(135deg, #722ed1 0%, #9254de 100%);
  border: none;
  color: white;
}

.view-btn:hover {
  background: linear-gradient(135deg, #531dab 0%, #722ed1 100%);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .page-header {
    padding: 16px;
  }

  .header-stats {
    flex-direction: column;
    gap: 12px;
  }

  .stat-item {
    width: 100%;
    min-width: auto;
  }

  .toolbar {
    flex-direction: column;
    gap: 12px;
    align-items: stretch;
  }

  .toolbar-right {
    justify-content: flex-end;
  }

  .action-buttons {
    justify-content: flex-start;
    flex-wrap: wrap;
  }
}
</style>
