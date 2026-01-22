<template>
  <div class="ele-body">
    <el-card shadow="never">
      <!-- 搜索表单 -->
      <el-form :model="where" label-width="77px" class="ele-form-search" @keyup.enter.native="reload"
        @submit.native.prevent>
        <el-row :gutter="15">
          <el-col :lg="6" :md="12">
            <el-form-item label="用户账号:">
              <el-input clearable v-model="where.username" placeholder="请输入用户账号" />
            </el-form-item>
          </el-col>
          <el-col :lg="6" :md="12">
            <el-form-item label="性别:">
              <el-select clearable v-model="where.gender" placeholder="请选择性别" class="ele-fluid">
                <el-option label="男" value="1" />
                <el-option label="女" value="2" />
                <el-option label="保密" value="3" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :lg="6" :md="12">
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
        height="calc(100vh - 315px)">
        <!-- 表头工具栏 -->
        <template slot="toolbar">
          <el-button @click="openEdit(null)" type="primary" icon="el-icon-plus" class="ele-btn-icon" size="small">添加
          </el-button>
          <el-button @click="removeBatch" type="danger" icon="el-icon-delete" class="ele-btn-icon" size="small">删除
          </el-button>
        </template>
        <!-- 用户名列 -->
        <template slot="realname" slot-scope="{ row }">
          <router-link :to="'/system/user/info?id=' + row.id">
            {{ row.realname }}
          </router-link>
        </template>
        <!-- 性别列 -->
        <template slot="gender" slot-scope="{ row }">
          <el-tag :type="['success', 'primary', 'warning'][row.gender - 1]" size="mini">
            {{ ["男", "女", "保密"][row.gender - 1] }}
          </el-tag>
        </template>
        <!-- 头像 -->
        <template slot="avatar" slot-scope="{ row }">
          <el-avatar shape="square" :size="25" :src="row.avatar" />
        </template>
        <!-- 角色列 -->
        <template slot="roles" slot-scope="{ row }">
          <el-tag v-for="item in row.roles" :key="item.id" size="mini" type="primary" :disable-transitions="true">
            {{ item.name }}
          </el-tag>
        </template>
        <!-- 状态列 -->
        <template slot="status" slot-scope="{ row }">
          <!--el-tag v-if="row.status === 1" size="mini">启用 </el-tag>
          <el-tag v-if="row.status === 2" type="info" size="mini">停用 </el-tag-->
          <el-switch v-if="row.id !== 1" v-model="row.status" @change="editStatus(row)" :active-value="1"
            :inactive-value="2" />
          <el-tag v-else size="mini">启用 </el-tag>
        </template>
        <!-- 操作列 -->
        <template slot="action" slot-scope="{ row }">
          <div>
            <el-link type="primary" :underline="false" icon="el-icon-edit" @click="openEdit(row)" v-if="row.id !== 1">修改
            </el-link>
            <el-popconfirm class="ele-action" title="确定要删除此用户吗？" @confirm="remove(row)">
              <el-link type="danger" slot="reference" :underline="false" icon="el-icon-delete" v-if="row.id !== 1">删除
              </el-link>
            </el-popconfirm>
          </div>
          <div>
            <el-popconfirm class="ele-action" title="确定要重置密码吗？" @confirm="resetPwd(row)">
              <el-link type="success" slot="reference" :underline="false" icon="el-icon-key"
                v-if="row.id !== 1">重置密码
              </el-link>
            </el-popconfirm>
          </div>
        </template>
      </ele-pro-table>
    </el-card>
    <!-- 编辑弹窗 -->
    <user-edit :data="current" :visible.sync="showEdit" @done="reload" />
    <!-- 显示密码 -->
    <password-copy :data="text" :visible.sync="showPassword" />
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import UserEdit from "./user-edit";
import PasswordCopy from "./password-copy";

export default {
  name: "SystemUser",
  components: { UserEdit, PasswordCopy },
  computed: {
    ...mapGetters(["permission"]),
  },
  data() {
    return {
      // 表格数据接口
      url: "/admin/list",
      text: "",
      // 表格列配置
      columns: [
        {
          columnKey: "selection",
          type: "selection",
          width: 45,
          align: "center",
          fixed: "left",
        },
        {
          prop: "id",
          label: "ID",
          width: 60,
          align: "center",
          showOverflowTooltip: true,
          fixed: "left",
        },
        {
          prop: "username",
          label: "用户账号",
          align: "center",
          showOverflowTooltip: true,
          minWidth: 110,
        },
        {
          prop: "realname",
          label: "用户姓名",
          align: "center",
          showOverflowTooltip: true,
          minWidth: 110,
          slot: "realname",
        },
        {
          prop: "genderName",
          label: "性别",
          align: "center",
          showOverflowTooltip: true,
          minWidth: 60,
          slot: "gender",
        },
        {
          prop: "mobile",
          label: "手机号",
          align: "center",
          showOverflowTooltip: true,
          minWidth: 60,
        },
        {
          columnKey: "roles",
          label: "角色",
          align: "center",
          showOverflowTooltip: true,
          minWidth: 200,
          slot: "roles",
        },
        {
          prop: "status",
          label: "状态",
          align: "center",
          width: 100,
          resizable: false,
          slot: "status",
        },
        {
          prop: "intro",
          label: "简介",
          align: "center",
          resizable: false,
        },
        {
          prop: "createdAt",
          label: "创建时间",
          align: "center",
          showOverflowTooltip: true,
          formatter: (row, column, cellValue) => {
            const date = new Date(cellValue);
            return this.$util.toDateString(date);
          },
        },
        {
          prop: "updatedAt",
          label: "更新时间",
          align: "center",
          showOverflowTooltip: true,
          formatter: (row, column, cellValue) => {
            const date = new Date(cellValue);
            return this.$util.toDateString(date);
          },
        },
        {
          columnKey: "action",
          label: "操作",
          width: 220,
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
      // 是否显示密码
      showPassword: false,
      // 是否显示导入弹窗
      showImport: false,
    };
  },
  methods: {
    /* 刷新表格 */
    reload() {
      this.$refs.table.reload({ where: this.where });
    },
    /* 重置搜索 */
    reset() {
      this.where = {};
      this.reload();
    },
    /* 显示编辑 */
    openEdit(row) {
      this.current = row;
      this.showEdit = true;
    },
    /* 删除 */
    remove(row) {
      const loading = this.$loading({ lock: true });
      this.$http
        .post("/sysUser/delete", [row.id])
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
      this.$confirm("确定要删除选中的用户吗?", "提示", {
        type: "warning",
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
                this.$message({ type: "success", message: res.data.message });
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
        .post("/admin/updateStatus", params)
        .then((res) => {
          loading.close();
          if (res.data.code === 200) {
            this.$message({ type: "success", message: res.data.message });
            this.reload();
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
    /**
     * 重置密码
     */
    resetPwd(row) {
      const loading = this.$loading({ lock: true });
      this.$http
        .post("/admin/resetPassword/" + row.id)
        .then((res) => {
          loading.close();
          if (res.data.code === 200) {
            this.showPassword = true;
            this.text = res.data.data;
          } else {
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
